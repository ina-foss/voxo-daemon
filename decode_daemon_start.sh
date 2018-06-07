#!/bin/bash
 
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Need Xvfb for mono
export DISPLAY="localhost:10.0"

ROOTDIR=/home/asr/asr/voxo-daemon/
USER=asr # the user to run as
GROUP=asr # the group to run as
# Activate the virtual environment
cd $ROOTDIR
source ./env/bin/activate
export PYTHONPATH=$ROOTDIR:$PYTHONPATH
 
/etc/init.d/xvfb start

exec ./decode_daemon.py -n

