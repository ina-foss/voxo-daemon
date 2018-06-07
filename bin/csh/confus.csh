#!/bin/csh
set expe=$1
shift
set num=$1
shift
set langue=$1
shift
set sphinx=$1
shift
source conf/sphinx_param
set wipP4=$wip
set lwP4=$lw
source conf/sphinx_param
set lat=$expe/latp4
mkdir -p $expe/latp5
echo DATESTART `date `
java -Xmx4000m -cp $sphinx -Dfsmdir=$expe/latp5 -Dprune=30 -Dlm=trigramModelrienderien -Dlatdir=$lat -Dseuil=0.0001 \
    -Ddictionary'[dictionaryPath]=file:'$langue'/dico/'$vocab \
    -Ddictionary'[fillerPath]=file:'$langue'/dico/dico-noyau.filler' \
    -Dwip=${wipP4} \
    -DlanguageWeight=${lwP4} \
     -Dfile.encoding=ISO8859-1\
#   -Dbatch'[beginSkip]'=0 \
#    -Dbatch'[count]'=10 \
 edu.cmu.sphinx.tools.batch.BatchConfucius conf/confuspar.config.xml $expe/ctl/sat$num.ctl>& $expe/log/passe5$num.log
if ($status) exit $status
echo DATEEND `date +%s`
exit 

