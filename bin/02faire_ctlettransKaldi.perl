#!/usr/bin/perl -w
open (TRANS,">$ARGV[0].trans") or die "pas ouvert trans\n";
open (CTL,">$ARGV[0].ctl") or die "pas ouvert CTL\n";
shift;
$deca=0;
if ($#ARGV>=0) {
    $deca=$ARGV[0];
    shift;
}
while (<>) {
    @res = /\S+/g;
    $debut =  $res[2]*100;
    $debut-=$deca;
    $fin =    $res[3]*100-1;
    $fin+=$deca;
#    next if ($fin-$debut >10000 );
    $debut = ($debut <0) ? 0: $debut;
    printf CTL "%s %1.0f %1.0f ",$res[0], $debut, $fin;
    print CTL  join("-",@res[0,2..4]),"\n";
    print TRANS join(' ',@res[5..$#res])," (",join("-",@res[0,2..4]),")\n";
}
close(TRANS);
close(CTL);
