#!/usr/bin/env python3
import logging
import multiprocessing
import os
import re
import simpledaemon
import time
import settings
from daemon import Daemon

logger = logging.getLogger(__name__)


class DecodeDaemon(simpledaemon.Daemon):
    default_conf = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                'daemon.conf')

    section = 'decode'

    def alive_jobs(self, jobs):
        return [j for j in jobs if j.is_alive()]

    def run(self):

        self.dashboard_ip = None

        if settings.DASHBOARD_IP_ENV is not None:
            self.dashboard_ip = os.environ.get(settings.DASHBOARD_IP_ENV)

        daemon = Daemon(
            settings.DASHBOARD_TOKEN,
            settings.OUTPUT_DIR,
            settings.SCRIPTS_DIR,
            settings.SPEED,
            settings.MODELS
        )

        jobs = []
        max_jobs = settings.NUM_THREADS

        processes = []
        decoded_processes = {}

        while True:

            # If there is no process or we have less processes
            if len(processes) == 0 or \
                    len(processes) < len(self.alive_jobs(jobs)):

                new_processes = \
                    daemon.get_processes_to_decode(
                        self.get_url(settings.DECODE_URLS['PROCESS_LIST']))

                # Try to avoid race conditions
                processes = \
                    processes + \
                    [p for p in new_processes
                        if p["id"] not in decoded_processes]

                if len(processes) == 0:

                    daemon.delete_file_list(
                        self.get_url(settings.DECODE_URLS['FILES_TO_DELETE']),
                        settings.DECODE_URLS['UPDATE'])

                    time.sleep(5)
                    continue

            # We have nothing to do, kill zombies
            if len(self.alive_jobs(jobs)) == 0:
                while multiprocessing.active_children():
                    time.sleep(1)

            if len(self.alive_jobs(jobs)) < max_jobs:
                process = processes[0]
                decoded_processes[process["id"]] = True
                processes = processes[1:]

                p = multiprocessing.Process(
                        target=daemon.decode_process,
                        args=(
                            process,
                            self.get_url(settings.DECODE_URLS['DOWNLOAD']),
                            self.get_url(
                                settings.DECODE_URLS['UPDATE_PROCESS']),
                            self.get_url(settings.DECODE_URLS['UPLOAD']),
                            self.get_url(settings.DECODE_URLS['GET_FILE']))
                )

                p.daemon = True
                jobs.append(p)
                p.start()
            else:
                # We are full, kill zombies (join terminated processes)
                while multiprocessing.active_children():
                    time.sleep(1)

            daemon.delete_file_list(
                self.get_url(settings.DECODE_URLS['FILES_TO_DELETE']),
                settings.DECODE_URLS['UPDATE'])

    def get_url(self, value):

        if self.dashboard_ip is not None:
            value = re.sub(
                r"([^\/]*\/\/)[^\/]*(.*)", r"\1PLACE_HOLDER\2", value)\
                           .replace('PLACE_HOLDER', self.dashboard_ip)

        return value


if __name__ == '__main__':
    DecodeDaemon().main()
