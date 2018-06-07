# -*- coding: utf-8 -*-
import glob
import logging
import os
import shutil


logger = logging.getLogger(__name__)


class DecodeTools:

    def __init__(self):
        pass

    def clean_decoding_file(self, output_dir, file_name, all=True):

        download_file_name = os.path.abspath(
            os.path.join(output_dir, 'download', file_name))

        # The project name is the audio filename without the extension
        project_name = os.path.splitext(os.path.basename(file_name))[0]
        project_dir = os.path.join(output_dir, 'results', project_name)

        logger.info('Tying to clean {} and {}'.format(
            download_file_name, project_dir))

        if os.path.exists(download_file_name):
            logger.info('Cleaning {}'.format(download_file_name))
            os.remove(download_file_name)

        if all:
            if os.path.exists(project_dir):
                logger.info('Cleaning {}'.format(project_dir))
                shutil.rmtree(project_dir)
        else:
            # Delete only the biggest dirs
            if os.path.exists(
                    os.path.join(project_dir, 'audio')):
                shutil.rmtree(
                    os.path.join(project_dir, 'audio'))

            if os.path.exists(
                    os.path.join(project_dir, 'decode', 'mfcc_hires')):
                shutil.rmtree(
                    os.path.join(project_dir, 'decode', 'mfcc_hires'))

            for f in glob.glob(os.path.join(
                    project_dir, 'decode', 'ivectors', 'ivector*')):
                os.remove(f)
