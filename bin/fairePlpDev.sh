#!/bin/bash
export LC_ALL=C
# Qsub
#set train_cmd="queue.2.pl --ram 4G --thread 2"
# Normal
train_cmd="run.pl"
nj=1
JOB=1:$nj
steps/make_plp.sh --plp_config conf/$2 --nj ${nj} --cmd "$train_cmd"  $1   $1   $1/plpDir || exit 1;
steps/compute_cmvn_stats.sh   $1   $1/log   $1/plpDir
exit
