#!/bin/csh
if ( $?PBS_O_WORKDIR ) then
cd $PBS_O_WORKDIR
endif
uname -n
echo $LANG
set PRECMLLR=false
set expe=$1
shift
set num=$1
shift
set bande=$1
shift
set cond=$1
shift
set cmllr=false
set go=$1
shift
set langue=$1
shift
set sphinx=$1
shift
set duree=0.4
set P2=norm
set P1=norm
set BIGRAM=no
set grosGraphe=0
source conf/sphinx_param
goto $go
P1:
P2:
PFEAT:
P3:
P4:
if ( -e ${expe}/ctl/sat${num}.stm && ! -e  ${expe}/ctl/sat${num}.ctl ) then
02faire_ctlettransKaldi.perl ${expe}/ctl/sat${num}  <${expe}/ctl/sat${num}.stm 
endif

#4G

echo "####################"
astarKaldi.csh  $expe $num $langue
echo "END ####################"
#confus
P5:
confus.csh  $expe $num $langue $sphinx

