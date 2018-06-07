#!/bin/bash

expe=$1
shift
num=$1
shift
langue=$1
shift
sphinx_param=$1
shift
lw=1
silprob=0.1
fillprob=0.05
wip=1
poidspron=0.1
ordre=4
poidsCslm=1
#setenv PATH /lium/paroleg/paul/src/lm_tools_32bits_file64bits/programs:$PATH
source $sphinx_param
wipP4=$wip
lwP4=$lw
fillprobP4=$fillprob
extension=lat.gz

if [[ $ordre == 4 || $ordre == 3 ]]; then 
    if [ $ordre == 3 ]; then
        mkdir -p $expe/latp4/
        sortie=$expe/latp4/
    else
        mkdir -p $expe/latp3/
        sortie=$expe/latp3/

        echo "####### SORTIE $sortie"

    fi

    mkdir -p $expe/resultat_2
    cardi=`wc -l ${expe}/ctl/sat${num}.ctl|awk '{print $1}'`
    s3astar \
        -ctl ${expe}/ctl/sat$num.ctl \
        -dagfudge 0 \
        -dict $langue/dico/$vocab  \
        -fdict $langue/dico/dico-noyau.filler \
            -inlatdir ${expe}/latp2 \
        -lm $langue/lm/$lm3 \
        -ngram 3 \
        -lw $lw \
        -logbase 1.0003  \
        -min_endfr 1 \
        -maxlpf 100000 \
        -nbest 3000 \
        -maxedge 30000000 \
        -beamastar 1e-65 \
        -nbestext lat.gz \
        -nbestdir $sortie \
            -fillprob $fillprob \
            -silprob $silprob \
        -wip $wip  \
        -bestorlat false \
        -htkin true \
            -latext lat.gz \
        -ppathdebug no \
        -ctmfp ${expe}/resultat_2/${num}_${cardi}.hyp \
        >& $expe/log/passe3${num}.log

    if [[ $? == 1 ]]; then
        exit $?
    fi

    if [[ $ordre == 3 ]]; then
        exit
    fi
fi



echo DATESTART `date +%s`


vocabP=$vocab:r.proba
if [ -e $langue/dico/$vocabP ]; then
    vocab=$vocabP
fi

mkdir -p $expe/latp4
comcslm=""
if [[ -z $cslm && "$clsm" -ne "" ]]; then
    comcslm="-cslm $langue/lm/$cslm -poidscslm $poidsCslm  "
fi

if [ $ordre == 5 ]; then 
    extension=lat.gz
    lm4=$lm5
fi
mkdir -p $expe/CTM.astar
cardi=`wc -l ${expe}/ctl/sat${num}.ctl|awk '{print $1}'`
maxLRU=100000
inlatdir=${expe}/latp3/

if [ "$BIGRAM" == "java" ]; then
    inlatdir=${expe}/latp2/
    maxLRU=10000000

fi

maxLRU=10000000  # pour rescorer des tri de p2

s3astar \
	 -ctl ${expe}/ctl/sat$num.ctl  $comcslm \
	-dagfudge 0 \
	-dict $langue/dico/$vocab  \
	-fdict $langue/dico/dico-noyau.filler \
        -inlatdir $inlatdir \
	-lm $langue/lm/$lm4 \
	-ngram $ordre \
	-lw ${lwP4} \
	-logbase 1.0003  \
	-min_endfr 1 \
	-maxlpf 100000 \
	-nbest 3000 \
	-beamastar 1e-65 \
	-nbestext lat.gz \
	-nbestdir $expe/latp4 \
        -fillprob $fillprobP4 \
        -silprob $silprob \
	-wip ${wipP4}  \
	-bestorlat false \
	-htkin true \
        -latext $extension \
	-ppathdebug no \
	-ctmfp ${expe}/CTM.astar/ctm${num}_${cardi}.ctm \
    >& $expe/log/passe4${num}.log


if [ $? -ne 0 ]; then
    exit $?
fi

echo DATEEND `date +%s`
