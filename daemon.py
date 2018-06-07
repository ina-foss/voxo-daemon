# -*- coding: utf-8 -*-
import concurrent.futures
from datetime import datetime
import json
import logging
import os
import time
from urllib.parse import urlparse

from requests.adapters import HTTPAdapter

from decode_tools import DecodeTools
from voxolab.models import DecodeStatus, ProcessType, FileStatus
from voxolab.resilientsession import ResilientSession
import fast_decode

logger = logging.getLogger(__name__)
logging.getLogger("requests").setLevel(logging.WARNING)


class Daemon:

    def __init__(self, token, output_dir, scripts_dir,
                 speed=0.4, models={}):

        self.token = token
        self.session = ResilientSession()

        self.session.headers.update({'Authentication-Token': token})
        self.output_dir = output_dir
        self.scripts_dir = scripts_dir
        self.tools = DecodeTools()
        self.speed = float(speed)
        self.models = models

        if (not os.path.exists(self.output_dir)):
            os.makedirs(self.output_dir)
        if (not os.path.exists(os.path.join(self.output_dir, 'results'))):
            os.makedirs(os.path.join(self.output_dir, 'results'))
        if (not os.path.exists(os.path.join(self.output_dir, 'download'))):
            os.makedirs(os.path.join(self.output_dir, 'download'))
        if (not os.path.exists(os.path.join(self.output_dir, 'done'))):
            os.makedirs(os.path.join(self.output_dir, 'done'))

    def delete_file_list(self, files_to_delete_url, update_file_url):
        """ Get the file list to delete from the server """

        # Increase max retries
        parsed_uri = urlparse(files_to_delete_url)
        domain = '{uri.scheme}://{uri.netloc}/'.format(uri=parsed_uri)
        self.session.mount(domain, HTTPAdapter(max_retries=1))

        r = self.session.get(files_to_delete_url, allow_redirects=False,
                             timeout=10)

        if(r.status_code == 401):
            logger.error("Wrong token provided.")
            return

        if(r.status_code == 302):
            logger.error("You need server credentials to get the file list.")
            return

        files = r.json()

        if(len(files) > 0):
            file = files[0]
            self.tools.clean_decoding_file(self.output_dir,
                                           file['generated_filename'])
            self.session.put(update_file_url.format(str(file['id'])),
                             data='{"status":' + str(FileStatus.Deleted)+'}')

    def get_processes_to_decode(self, process_list_url):
        """ Get the file list to decode from the server """

        # Increase max retries
        parsed_uri = urlparse(process_list_url)
        domain = '{uri.scheme}://{uri.netloc}/'.format(uri=parsed_uri)
        self.session.mount(domain, HTTPAdapter(max_retries=1))

        r = self.session.get(
            process_list_url, allow_redirects=False, timeout=10)

        if(r.status_code == 401):
            logger.error("Wrong token provided.")
            return []

        if(r.status_code == 302):
            logger.error("You need server credentials to get the file list.")
            return []

        processes = r.json()

        return processes

    def decode_process(self, process, download_url,
                       update_process_url, upload_url, get_file_url):
        """ Decode one process """

        # Download the file from the server
        if(self.download_process_file(process, download_url)):
            print(process)
            decode_result = self.decode_file(process, update_process_url,
                                             upload_url, get_file_url)

            self.tools.clean_decoding_file(
                self.output_dir, process['file_name'], all=False)

            return decode_result
        else:
            self.update_process(update_process_url, process['id'],
                                self.session, DecodeStatus.Error, 0, 0)
            logger.error('Error downloading ' + process['file_name'])

        return -1

    def upload_file(self, url, file_id, filename):
        return self.session.post(
            url.format(file_id),
            files={'file': open(filename, 'rb')}
        )

    def update_process(self, url, file_id, session,
                       status=None, duration=None, progress=None):

        data = {}

        if status:
            data['status'] = status

        if duration:
            data['duration'] = str(duration)

        if progress:
            data['progress'] = str(progress)

        response = session.put(
            url + str(file_id),
            data=json.dumps(data)
            )

        return response

    def decode_file(self, process, update_process_url, upload_url,
                    get_file_url):

        # Inform the server that we have started the decoding process
        self.update_process(update_process_url, process['id'],
                            self.session, DecodeStatus.Started)

        startTime = datetime.now()

        # Start decoding
        return_code = self.start_decode(process, self.tools,
                                        self.output_dir,
                                        self.scripts_dir,
                                        self.session, update_process_url,
                                        get_file_url)

        total_duration = datetime.now() - startTime

        basename = os.path.splitext(process['file_name'])[0]
        output_dir = os.path.join(self.output_dir, 'results', basename)
        ctm_output_file = os.path.join(output_dir, basename + '.ctm')

        if(not os.path.isfile(ctm_output_file) or
           os.path.getsize(ctm_output_file) == 0):
            return_code = -2

        if(return_code == 0):
            # Everything's fine, let's update the process
            # with the finish state
            output_formats = ['.srt', '.vtt', '.xml',
                              '.txt', '.v2.xml', '.scc']

            try:
                for file_format in output_formats:
                    file_to_upload = os.path.join(
                        output_dir, basename + file_format)

                    # Only upload file if it exists
                    if os.path.isfile(file_to_upload):
                        self.upload_file(
                            upload_url, process['file_id'],
                            file_to_upload
                        )

                self.update_process(update_process_url, process['id'],
                                    self.session, DecodeStatus.Finished,
                                    total_duration, 100)

                msg = "Everything went fine"
            except Exception as e:
                logger.exception(e)
                msg = "Error when uploading result files"
                return_code = -1
                self.update_process(update_process_url, process['id'],
                                    self.session, DecodeStatus.Error,
                                    total_duration)

        elif (return_code == -2):
            self.update_process(update_process_url, process['id'],
                                self.session, DecodeStatus.Error,
                                total_duration)
            msg = 'Empty file. Error decoding ' + process['file_name']
            logger.error(msg)
            return (-2, msg)
        else:
            self.update_process(update_process_url, process['id'],
                                self.session, DecodeStatus.Error,
                                total_duration)
            msg = 'Error decoding ' + process['file_name']
            logger.error(msg)

        return (return_code, msg)

    def start_decode(self, process, tools, output_dir, scripts_dir,
                     session, update_process_url, get_file_url):

        return_code = -1
        try:
            filename = os.path.abspath(
                os.path.join(output_dir, 'download',
                             process['file_name'])
            )

            output_dir = os.path.abspath(
                os.path.join(output_dir, 'results')
            )
            if process['type_id'] == ProcessType.CustomModelTranscription:
                model = process['asr_model_name']
            elif process['type_id'] == ProcessType.FullEnglishTranscription:
                model = 'english.studio'
            else:
                model = 'french.studio.fr_FR'

            self.send_progress(
                process, update_process_url, get_file_url, self.speed)

            return_code = fast_decode.docker_decode(
                    filename,
                    output_dir,
                    model,
                    self.models,
                    scripts_dir)

        except Exception as e:
            logger.exception(e)
            return_code = -1

        return return_code

    # http://stackoverflow.com/questions/29177490/
    # how-do-you-kill-futures-once-they-have-started
    def send_progress(self, process, update_process_url,
                      get_file_url, speed=0.4):

        r = self.session.get(get_file_url.format(str(process['file_id'])))
        file = r.json()

        print(file['duration'])
        total_time = int(file['duration']*speed)

        def update_file():
            time_elapsed = 0
            waiting_time = 1
            progress = 0
            while progress <= 100 and total_time > 0:
                try:
                    progress = (time_elapsed*100/total_time)

                    if(progress < 100):
                        self.update_process(update_process_url, process['id'],
                                            self.session,
                                            progress=int(progress))
                        time.sleep(waiting_time)
                        time_elapsed = time_elapsed + waiting_time
                    else:
                        break

                except Exception as e:
                    logger.exception(e)
                    print("#### Exception")

        executor = concurrent.futures.ThreadPoolExecutor(max_workers=5)
        executor.submit(update_file)

    def download_process_file(self, process, download_url):
        """ Download a file from the server and save it locally """

        if(not os.path.isfile(os.path.join(self.output_dir,
                                           process['file_name']))):

            r = self.session.get(download_url + str(process['file_id']),
                                 stream=True)
            if(r.status_code == 200):
                # Save each file locally
                with open(os.path.join(self.output_dir,
                                       'download',
                                       process['file_name']), 'wb') as handle:

                    for block in r.iter_content(1024):
                        if not block:
                            break

                        handle.write(block)
            else:
                logger.error('Download of file ' + process['file_name'] +
                             ' failed: ' + str(r.status_code))
                return False
        else:
            logger.info('Skipping ' + process['file_name'] +
                        ' because it was already downloaded.')
        return True
