#!/bin/bash
expe=$1
lang=$2
lat=$3
htkScript=$4
latticeToPhoneWithKeepTime=$5
mkdir -p $lat
mod=$expe/../
pasOk=0
files=( $expe/lat.1.gz $mod/final.mdl $lang/words.txt $lang/phones.txt $lang/phones/word_boundary.int ) 
for i in "${files[@]}"
do
    if [ ! -e $i ]
    then
        echo pas vu $i
        pasOk=1
    fi
done
if [ $pasOk == 1 ] 
then
    echo "Pas ok $pasOk"
    exit 1
fi



#gunzip -c $expe/lat.*.gz | /lium/paroleg/paul/src/kaldi/kaldi-trunk.temp/src/latbin/lattice-align-words $lang/phones/word_boundary.int $mod/final.mdl ark:- ark:- | /lium/paroleg/paul/src/kaldi/kaldi-trunk.temp/src/latbin/lattice-to-phone-lattice --keepTime=2 --replace-words=false $mod/final.mdl ark:- ark,t:- | utils/int2sym.pl -f 3 $lang/words.txt | phonetise.perl $lang/phones.txt | ( cd $lat  ; toHtk.perl )

echo "gunzip -c $expe/lat.*.gz | /lium/paroleg/paul/src/kaldi/kaldi-trunk.temp/src/latbin/lattice-align-words $lang/phones/word_boundary.int $mod/final.mdl ark:- ark:- | $latticeToPhoneWithKeepTime --keepTime=2 --replace-words=false $mod/final.mdl ark:- ark,t:- | utils/int2sym.pl -f 3 $lang/words.txt | phonetise.perl $lang/phones.txt | ( cd $lat  ; $htkScript )"

gunzip -c $expe/lat.*.gz | lattice-align-words $lang/phones/word_boundary.int $mod/final.mdl ark:- ark:- | $latticeToPhoneWithKeepTime --keepTime=2 --replace-words=false $mod/final.mdl ark:- ark,t:- | utils/int2sym.pl -f 3 $lang/words.txt | phonetise.perl $lang/phones.txt | ( cd $lat  ; $htkScript )

exit 0

