import os

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

OUTPUT_DIR = "/opt/asr/output"
SCRIPTS_DIR = os.path.join(BASE_DIR, "bin")

DECODE_CMD = "optirun /home/vjousse/usr/src/voxolabvoxo-fast/run_phone.sh /opt/asr/output/download/{file} /opt/asr/output/results/ yes 8 {lm} {graph} {model} /opt/asr/models/phone/extractor diarization-fast.sh decode_nnet3_phone.sh 300 8000 14.0 0.08333"
 
SPEED = 0.4
NUM_THREADS = 2

DASHBOARD_URL = "http://127.0.0.1:5000"
DASHBOARD_TOKEN = "SecretToken"
MODELS_BASE_PATH = "/opt/asr/models/phone"
VOXO_FAST_PATH = "optirun /home/vjousse/usr/src/voxolab/voxo-fast"

DECODE_URLS = {
    'PROCESS_LIST': DASHBOARD_URL + '/api/internal/processes',
    'DOWNLOAD': DASHBOARD_URL + '/api/internal/download/',
    'UPLOAD': DASHBOARD_URL + '/api/files/{0}/transcription',
    'UPDATE': DASHBOARD_URL + '/api/internal/files/{0}',
    'FILES_TO_DELETE': DASHBOARD_URL + '/api/internal/files?status=4',
    'UPDATE_PROCESS': DASHBOARD_URL + '/api/internal/processes/',
    'GET_FILE': DASHBOARD_URL + '/api/internal/files/{0}'
}

ALIGN_URLS = {
    'PROCESS_LIST': DASHBOARD_URL + '/api/internal/processes?type={}',
    'DOWNLOAD': DASHBOARD_URL + '/api/internal/download/{}?type={}',
    'UPLOAD': DASHBOARD_URL + '/api/internal/transcriptions/{}',
    'UPDATE': DASHBOARD_URL + '/api/internal/processes/'
}

MODELS = {
    'french.phone.fr_FR.vp4': {
        'DECODE_CMD': "{voxo_fast}/{run_cmd} {output_dir}/download/{file} {output_dir}/results/ {use_gpu} {num_threads} {lm} {graph} {model} {extractor} {diarization} {decode_script} {min_active} {max_active} {beam} {acwt}".format(
            file="{file}",
            voxo_fast=VOXO_FAST_PATH,
            run_cmd='run_phone.sh',
            output_dir=OUTPUT_DIR,
            use_gpu='yes',
            num_threads=8,
            lm=MODELS_BASE_PATH + '/4g_vp4',
            graph=MODELS_BASE_PATH + '/graph_vp4',
            model=MODELS_BASE_PATH + '/model',
            extractor=MODELS_BASE_PATH + '/extractor',
            diarization="diarization-fast.sh",
            decode_script="decode_nnet3_phone.sh",
            min_active=300,
            max_active=8000,
            beam=14.0,
            acwt=0.08333,),
        'PUNCTUATE_CMD': 'optirun /home/vjousse/usr/src/python/punctuator2/punctuate.sh /home/vjousse/usr/src/python/punctuator2/Model_authot_h256_lr0.02.pcl {}',
        'RECASE_DIR': None,
    },
}


# If any, put the name of the environment variable containing
# the ip address of the dashboard. Useful when we don't know
# the ip address in adavance. For example for two dockers on the
# the same host, we will know the dashboard ip only at runtime

DASHBOARD_IP_ENV = None
