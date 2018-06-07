#!/bin/bash
 
export LANG='en_GB.UTF-8'
export LC_ALL='en_GB.UTF-8'

ROOTDIR=/home/asr/asr/voxo-daemon/
USER=asr # the user to run as
GROUP=asr # the group to run as
# Activate the virtual environment
cd $ROOTDIR
source ./env/bin/activate
export PYTHONPATH=$ROOTDIR:$PYTHONPATH
 
exec ./align_daemon.py -n

