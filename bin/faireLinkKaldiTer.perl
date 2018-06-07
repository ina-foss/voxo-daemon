#!/usr/bin/perl -w

my $rep1=$ARGV[0];
shift;
my $repOut=$ARGV[0];
shift;
my $old="" ;
mkdir "$repOut";
while (<>) {
    @res = /\S+/g;
    $debut =  $res[2]*100;
    $fin =    $res[3]*100-1;
#    next if ($fin-$debut >10000 );
    $debut = ($debut <0) ? 0: $debut;
    @loc=split ('-',$res[4]);
    ($sexe) = $loc[0]=~/(.)$/;
    ($num)= $loc[1]=~ /S(\d+)/;
    my $showKaldi=$res[0];
#    $showKaldi=~ s/:/-/g;
    my $idKaldi=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debut,$fin,$sexe);
    my $idSph= "$repOut/".join("-",@res[0,2..4]).".lat.gz";
    print "ln -s   $idKaldi  $idSph\n";


}


