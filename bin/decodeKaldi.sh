#!/bin/bash
uname -n
echo $LANG
PRECMLLR=false
expe=$1
shift
num=$1
shift
bande=$1
shift
cond=$1
shift
cmllr=false
go=$1
shift
langue=$1
shift
sphinx=$1
shift
sphinx_param=$1
shift
duree=0.4
P2=norm
P1=norm
BIGRAM=no
grosGraphe=0
source $sphinx_param

if [[ -e ${expe}/ctl/sat${num}.stm && ! -e  ${expe}/ctl/sat${num}.ctl ]]
then
    02faire_ctlettransKaldi.perl ${expe}/ctl/sat${num}  <${expe}/ctl/sat${num}.stm 
fi

echo "####################"
astarKaldi.sh  $expe $num $langue $sphinx_param
echo "END ####################"

confus.sh  $expe $num $langue $sphinx $sphinx_param
