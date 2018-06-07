#!/usr/bin/perl -w
use strict;
my $deb=1;
my $expe= $ARGV[0];
my $expeBase;
my $passe="P1";
shift;
my $langueDir =shift @ARGV;
my $sphinx =shift @ARGV;
my $sphinx_param =shift @ARGV;

if ($#ARGV >=0) {
    
    $deb =shift @ARGV;
    $expeBase= shift @ARGV;
}
my %duree=("F0",200,"F2","100");
open STM," sort -k 1,1 -k 5,5 -k 3nb,3|" or die "pas ouvert $expe\n";
my $acond="";
my $tempo=0;
my $num=0;
my $anom="";
my $afich="";
mkdir "$expe/ctl";
mkdir "$expe/log";
mkdir "log/$expe";
mkdir "$expe/resultat_1";
mkdir "$expe/resultat_2";
mkdir "ctl/$expe";
my $out = "$expe/ctl/sat" . sprintf("%04d",$num).".stm";
open OUT,">$out" or die "pasouvert1 $out\n";
if ($deb> 1 && $deb<2) {
    $passe="PCMLLR";
    symlink "lat$expeBase","latp1/lat$expe";
    symlink "$expeBase","resultat_1/$expe";

}
$passe="P3";    

while (<STM>) {
    my @ligne=split;
    my $fich=$ligne[0];
    my ($cond,$nom) = $ligne[4] =~ /([^-]+)-(.*)/;
    if ($acond eq "") {$acond=$cond;$anom=$nom}
    my $bande=substr($acond,0,2);
    if ($acond ne $cond || ( ($anom ne $nom|| $afich ne $fich) &&  $tempo>$duree{$bande})){
	my $bande="bl";
	$bande="be" if ($acond =~/^F2/);
#	print "qsub etc/decode.csh $expe " . sprintf("%04d",$num)  ."  $bande $acond\n";
	#print "qsub -m n -q batch -e logpbs/$expe/$num.e -o logpbs/$expe/$num.o  -l walltime=20:01:00 -l mem=3500mb -v P1=$expe,P2=" . sprintf("%04d",$num)  .",P3=$bande,P4=$acond,P5=$passe  etc/envoieKaldi.csh\n";
#	print STDERR "tempo : $tempo loc $acond-$anom num: $num\n";

        print STDOUT "decodeKaldi.sh $expe " . sprintf("%04d",$num)  ." $bande $acond $passe $langueDir $sphinx $sphinx_param\n";
	$num++;
	my $out = "$expe/ctl/sat" . sprintf("%04d",$num).".stm";
	open OUT,">$out" or die "pasouvert2 $out\n";
	$acond=$cond;
	$tempo=0;
    }
    $anom=$nom;
    $afich=$fich;
    print OUT $_;
    $tempo += $ligne[3]-$ligne[2];
}

my $bande="bl";
$bande="be" if ($acond =~/^F2/);
#print "qsub -m n -q batch -e logpbs/$expe/$num.e -o logpbs/$expe/$num.o  -l walltime=20:01:00 -l mem=3500mb -v P1=$expe,P2=" . sprintf("%04d",$num)  .",P3=$bande,P4=$acond,P5=$passe  etc/envoieKaldi.csh\n";
print STDOUT "decodeKaldi.sh $expe " . sprintf("%04d",$num)  ." $bande $acond $passe $langueDir $sphinx $sphinx_param"
#print "qsub etc/decode.csh $expe " . sprintf("%04d",$num)  ."  $bande $acond\n";


