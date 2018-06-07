#!/bin/csh
set expe=$1
set lang=$2
set lat=$3
mkdir -p $lat
set mod=$expe:h
set pasOk=0
foreach i ( $expe/lat.1.gz $mod/final.mdl $lang/words.txt $lang/phones.txt $lang/phones/word_boundary.int) 
if ( ! -e $i ) then
echo pas vu $i
set pasOk=1
endif
end
if ( $pasOk ) exit 1



gunzip -c $expe/lat.*.gz | lattice-align-words $lang/phones/word_boundary.int $mod/final.mdl ark:- ark:- | lattice-to-phone-lattice --keepTime=2 --replace-words=false $mod/final.mdl ark:- ark,t:- | utils/int2sym.pl -f 3 $lang/words.txt | phonetise.perl $lang/phones.txt | ( cd $lat  ; toHtk.perl )

exit 0

