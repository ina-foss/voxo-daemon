#!/bin/csh
setenv LC_ALL C
# Qsub
#set train_cmd="queue.2.pl --ram 4G --thread 2"
# Normal
set train_cmd="run.pl"
set nj=1
set JOB=1:$nj
steps/make_plp.sh --plp_config conf/plp.conf --nj ${nj} --cmd "$train_cmd"  $1   $1   $1/plpDir || exit 1;
steps/compute_cmvn_stats.sh   $1   $1/log   $1/plpDir
exit

