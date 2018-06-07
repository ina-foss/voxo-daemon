#!/bin/bash
expe=$1
shift
num=$1
shift
langue=$1
shift
sphinx=$1
shift
sphinx_param=$1
shift
source $sphinx_param
wipP4=$wip
lwP4=$lw
lat=$expe/latp4
mkdir -p $expe/latp5
echo DATESTART `date `
java -Xmx4000m -cp $sphinx -Dfsmdir=$expe/latp5 -Dprune=30 -Dlm=trigramModelrienderien -Dlatdir=$lat -Dseuil=0.0001 \
    -Ddictionary'[dictionaryPath]=file:'$langue'/dico/'$vocab \
    -Ddictionary'[fillerPath]=file:'$langue'/dico/dico-noyau.filler' \
    -Dwip=${wipP4} \
    -DlanguageWeight=${lwP4} \
     -Dfile.encoding=ISO8859-1\
 edu.cmu.sphinx.tools.batch.BatchConfucius conf/confuspar.config.xml $expe/ctl/sat$num.ctl>& $expe/log/passe5$num.log
if [ $? -ne 0 ]; then 
    exit $?
fi

echo DATEEND `date +%s`
exit 

