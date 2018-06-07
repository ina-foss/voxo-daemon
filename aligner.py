#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging, argparse, sys, os, subprocess, requests
from time import sleep
from requests.adapters import HTTPAdapter
from voxolab.align_ref_with_decoding import align_xml
from voxolab.models import DecodeStatus, ProcessType
from voxolab.resilientsession import ResilientSession
from datetime import datetime
from urllib.parse import urlparse

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def align_file_list(file_list_url, download_url, update_process_url, upload_url, token, session, output_dir, mwerSegmenterBin):
    """ Get the file list to decode from the server """

    # Increase max retries
    parsed_uri = urlparse(download_url)
    domain = '{uri.scheme}://{uri.netloc}/'.format(uri=parsed_uri)
    session.mount(domain, HTTPAdapter(max_retries=1))

    #logger.info('Calling ' + file_list_url + ' with token: -{}-'.format(token))
    r = session.get(file_list_url, allow_redirects=False, timeout=10)

    if(r.status_code == 401):
        logger.error("Wrong token provided.")
        return

    if(r.status_code == 302):
        logger.error("You need server credentials to get the file list.")
        return

    processes = r.json()

    # Process each file that need to be decoded sequentially
    for process in processes:

        # Download the file from the server
        if(download_file(process, download_url, output_dir, token, session)):

            # Inform the server that we have started the decoding process
            session.put(update_process_url + str(process['id']), 
                    data = '{"status":' + str(DecodeStatus.Started)+ '}') 

            startTime = datetime.now()

            return_code = -1

            try:
                basename = os.path.splitext(process['transcription_ref_name'])[0]
                result_dir = os.path.join(output_dir, 'results')
                txt_output_file = os.path.abspath(os.path.join(result_dir, basename + '-aligned.txt'))
                logger.info("Aligning to {}".format(txt_output_file))

                with open(txt_output_file, "w") as output:
                    
                    authot_format = False

                    if(process['api_version'] == 'v1'):
                        authot_format = True

                    return_code = align_xml(os.path.abspath(os.path.join(output_dir, 'download', process['transcription_auto_name'])), os.path.abspath(os.path.join(output_dir, 'download', process['transcription_ref_name'])), mwerSegmenterBin, outfile=output, authot_format=authot_format)
                    logger.info("Aligning finished with return code {}".format(return_code))

            except Exception as e:
                logger.exception(e)
                return_code = -1

            total_duration = datetime.now()-startTime

            if(return_code == 0):
                # Everything's fine, let's update the process with the finish state
                session.post(upload_url.format(process['transcription_id']), files={'file': open(txt_output_file, 'rb')})

                session.put(update_process_url + str(process['id']), data = '{"status":' + str(DecodeStatus.Finished)+ ', "progress": 100, "duration":"' + str(total_duration) + '"}') 
            else:
                session.put(update_process_url + str(process['id']), data = '{"status":' + str(DecodeStatus.Error)+ ', "duration":"' + str(total_duration) + '"}') 
                logger.error('Error decoding ' + process['transcription_ref_name'])
        else:
            session.put(update_process_url + str(process['id']), data = '{"status":' + str(DecodeStatus.Error)+ ', "duration":"' + str(0) +'"}') 
            logger.error('Error downloading ' + process['transcription_ref_name'])



def download_file(process, download_url, output_dir, token, session):
    """ Download a file from the server and save it locally """

    for type in ['transcription_ref', 'transcription_auto']:
        if(not os.path.isfile(os.path.join(output_dir, process['transcription_ref_name']))):
            logger.info('Calling ' + download_url + ' with token: -{}-'.format(token))


            r = session.get(download_url.format(process['transcription_id'], type), stream=True)
            if(r.status_code == 200):
                # Save each file locally
                with open(os.path.join(output_dir, 'download', process['{}_name'.format(type)]), 'wb') as handle:
                    for block in r.iter_content(1024):
                        if not block:
                            break

                        handle.write(block)
            else:
                logger.error('Download of file ' + process['{}_name'.format(type)] + ' failed: ' + str(r.status_code))
                return False
        else:
            logger.info('Skipping ' + process['{}_name'.format(type)] + ' because it was already downloaded.')
    return True
