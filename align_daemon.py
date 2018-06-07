#!/usr/bin/env python3
import simpledaemon
import logging
import time, os
from daemon import Daemon
from aligner import align_file_list
from voxolab.resilientsession import ResilientSession
from voxolab.models import ProcessType

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AlignDaemon(simpledaemon.Daemon):
    if(os.path.isfile(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'daemon.conf'))):
        default_conf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'daemon.conf')
    else:
        default_conf = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'decode_daemon.conf')

    section = 'align'

    def run(self):

        logger.info('Start daemon')
        print('run')
        output_dir = self.config_parser.get('align', 'output_dir')
        token = self.config_parser.get('http', 'token')

        if (not os.path.exists(output_dir)):
            os.makedirs(output_dir)
        if (not os.path.exists(os.path.join(output_dir, 'results'))):
            os.makedirs(os.path.join(output_dir, 'results'))
        if (not os.path.exists(os.path.join(output_dir, 'download'))):
            os.makedirs(os.path.join(output_dir, 'download'))
        if (not os.path.exists(os.path.join(output_dir, 'done'))):
            os.makedirs(os.path.join(output_dir, 'done'))

        session = ResilientSession()
        session.headers.update({'Authentication-Token': token})


        process_list_url = self.config_parser.get('align', 'process_list_url').format(ProcessType.TranscriptionAlignment)

        while True:
            align_file_list(
                process_list_url,
                self.config_parser.get('align', 'download_url'),
                self.config_parser.get('align', 'update_process_url'),
                self.config_parser.get('align', 'upload_url'),
                token, 
                session,
                output_dir,
                self.config_parser.get('align', 'mwer_segmenter_bin')
                )


            time.sleep(5)

if __name__ == '__main__':
    AlignDaemon().main()
