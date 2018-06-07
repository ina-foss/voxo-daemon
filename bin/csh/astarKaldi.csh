#!/bin/csh

set expe=$1
shift
set num=$1
shift
set langue=$1
shift
set lw=1
set silprob=0.1
set fillprob=0.05
set wip=1
set poidspron=0.1
set ordre=4
set poidsCslm=1
#setenv PATH /lium/paroleg/paul/src/lm_tools_32bits_file64bits/programs:$PATH
source conf/sphinx_param
set wipP4=$wip
set lwP4=$lw
set fillprobP4=$fillprob
set extension=lat.gz

if ($ordre == 4 || $ordre == 3) then 
if ( $ordre == 3 ) then
mkdir -p $expe/latp4/
set sortie=$expe/latp4/
else
mkdir -p $expe/latp3/
set sortie=$expe/latp3/

echo "####### SORTIE $sortie"

endif
mkdir -p $expe/resultat_2
set cardi=`wc -l ${expe}/ctl/sat${num}.ctl|awk '{print $1}'`
s3astar \
     -ctl ${expe}/ctl/sat$num.ctl \
     -dagfudge 0 \
     -dict $langue/dico/$vocab  \
     -fdict $langue/dico/dico-noyau.filler \
        -inlatdir ${expe}/latp2 \
	-lm $langue/lm/$lm3 \
	-ngram 3 \
	-lw $lw \
    #-lw ${lwp} \
	-logbase 1.0003  \
	-min_endfr 1 \
	-maxlpf 100000 \
	-nbest 3000 \
	-maxedge 30000000 \
	-beamastar 1e-65 \
	-nbestext lat.gz \
	-nbestdir $sortie \
        -fillprob $fillprob \
#        -fillpen fillpen/$fillpen \
        -silprob $silprob \
    #-wip 0.06  \
	-wip $wip  \
	-bestorlat false \
	-htkin true \
        -latext lat.gz \
	-ppathdebug no \
	-ctmfp ${expe}/resultat_2/${num}_${cardi}.hyp \
    >& $expe/log/passe3${num}.log
if ($status) exit $status
if ( $ordre == 3 ) exit
endif 



echo DATESTART `date +%s`


set vocabP=$vocab:r.proba
if ( -e $langue/dico/$vocabP ) set vocab=$vocabP

mkdir -p $expe/latp4
set comcslm=""
if ( $?cslm) then
set comcslm="-cslm $langue/lm/$cslm -poidscslm $poidsCslm  "
endif

if ($ordre == 5 ) then 
  set extension=lat.gz
 set lm4=$lm5
endif
mkdir -p $expe/CTM.astar
set cardi=`wc -l ${expe}/ctl/sat${num}.ctl|awk '{print $1}'`
set maxLRU=100000
set inlatdir=${expe}/latp3
if ( $BIGRAM == java ) then
 set inlatdir=${expe}/latp2/
set maxLRU=10000000

endif
set maxLRU=10000000  # pour rescorer des tri de p2
s3astar \
	 -ctl ${expe}/ctl/sat$num.ctl  $comcslm \
	-dagfudge 0 \
	-dict $langue/dico/$vocab  \
	-fdict $langue/dico/dico-noyau.filler \
        -inlatdir $inlatdir \
	-lm $langue/lm/$lm4 \
	-ngram $ordre \
#	-lw 9.5 \
	-lw ${lwP4} \
	-logbase 1.0003  \
	-min_endfr 1 \
	-maxlpf 100000 \
	-nbest 3000 \
	-beamastar 1e-65 \
	-nbestext lat.gz \
	-nbestdir $expe/latp4 \
        -fillprob $fillprobP4 \
#        -fillpen fillpen/$fillpen \
        -silprob $silprob \
#	-wip 0.06  \
	-wip ${wipP4}  \
	-bestorlat false \
	-htkin true \
        -latext $extension \
	-ppathdebug no \
#	-poidspron $poidspron \
	-ctmfp ${expe}/CTM.astar/ctm${num}_${cardi}.ctm \
    >& $expe/log/passe4${num}.log


if ($status) exit $status
echo DATEEND `date +%s`
