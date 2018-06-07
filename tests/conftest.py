import os
import pytest

from tests.session import Session, Response
import fast_decode
from daemon import Daemon

#@pytest.fixture(autouse=True)
@pytest.fixture()
def no_requests(monkeypatch):
    monkeypatch.delattr("requests.sessions.Session.request")

@pytest.fixture()
def urls():
    urls = {}

    urls['process_list_url'] = "http://localhost:5000/api/internal/processes"
    urls['download_url'] = "http://localhost:5000/api/internal/download/"
    urls['upload_url'] = "http://localhost:5000/api/files/{0}/transcription"
    urls['update_file_url'] = "http://localhost:5000/api/internal/files/{0}"
    urls['files_to_delete_url'] = "http://localhost:5000/api/internal/files?status=4"
    urls['update_process_url'] = "http://localhost:5000/api/internal/processes/"
    urls['get_file_url'] = "http://localhost:5000/api/internal/files/{0}"

    return urls

@pytest.fixture()
def fake_daemon(no_requests, process_list_json, tmpdir, monkeypatch):

    # Don't decode for real
    def fake_docker_decode(file_path, output_dir, command, docker_audio_dir, 
                           docker_output_dir,conf, scripts_dir):
        # Everything went fine
        return 0

    monkeypatch.setattr(fast_decode, 'docker_decode',
                        fake_docker_decode)


    decode_daemon = Daemon(
        'token',
        tmpdir.strpath,
        'conf',
        'dir',
        'phone_conf',
        'en_conf'
    )


    response = Response(json_string=process_list_json)
    monkeypatch.setattr(decode_daemon, 'session', Session(response))

    # Let's do as if the download is ok
    monkeypatch.setattr(decode_daemon, 'download_process_file', lambda a,b: True)
    monkeypatch.setattr(decode_daemon, 'upload_file', lambda a,b,c: True)
    monkeypatch.setattr(decode_daemon, 'update_process', 
                        lambda a,b,c,d,e=None,f=None: True)
    monkeypatch.setattr(decode_daemon, 'send_progress', 
                        lambda a,b,c,e=0.4: True)

    return decode_daemon

@pytest.fixture()
def process_list_json(wav_file):

  return """[
  {{
    "duration": null,
    "file_id": 3,
    "file_name": "{wav}",
    "id": 12,
    "progress": 0,
    "status": "Queued",
    "status_id": 1,
    "transcription_auto_name": null,
    "transcription_id": null,
    "transcription_ref_name": null,
    "type": "Full transcription",
    "type_id": 1
  }}
]""".format(wav=wav_file)

@pytest.fixture()
def base_file():
    return "lcp_q_gov_a94b9c74_fa07_4d9a_a937_b2aeeddb3830"


@pytest.fixture()
def wav_file(base_file):
    return base_file + ".wav"

@pytest.fixture()
def ctm_file(base_file):
    return os.path.join("results", base_file, base_file + ".ctm")
