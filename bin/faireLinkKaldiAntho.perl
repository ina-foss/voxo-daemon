#!/usr/bin/perl -w

my $rep1=$ARGV[0];
shift;
my $repOut=$ARGV[0];
shift;
my $old="" ;
mkdir "$repOut";
while (<>) {
    @res = /\S+/g;
    $debutM1 = $res[2]*100-1;
    $debut =  $res[2]*100;
    $debutP1 = $res[2]*100+1;
    $finM1 = $res[3]*100-1;
    $fin =    $res[3]*100;
    $finP1 = $res[3]*100+1;
    next if ($fin-$debut >10000 );
    $debutM1 = ($debutM1 <0) ? 0: $debutM1;
    $debut = ($debut <0) ? 0: $debut;
    $debutP1 = ($debutP1 <0) ? 0: $debutP1;
    @loc=split ('-',$res[4]);
    ($sexe) = $loc[0]=~/(.)$/;
    ($num)= $loc[1]=~ /S(\d+)/;
    my $showKaldi=$res[0];
    $showKaldi=~ s/:/-/g;

    my $idKaldiM1M1=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debutM1,$finM1,$sexe);
    my $idfileM1M1=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debutM1,$finM1,$sexe);
    #my $idKaldiM1M1=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debutM1,$finM1,$sexe);
    #my $idfileM1M1=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debutM1,$finM1,$sexe);

    my $idKaldiM1_=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debutM1,$fin,$sexe);
    my $idfileM1_=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debutM1,$fin,$sexe);
    #my $idKaldiM1_=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debutM1,$fin,$sexe);
    #my $idfileM1_=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debutM1,$fin,$sexe);

    my $idKaldiM1P1=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debutM1,$finP1,$sexe);
    my $idfileM1P1=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debutM1,$finP1,$sexe);
    #my $idKaldiM1P1=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debutM1,$finP1,$sexe);
    #my $idfileM1P1=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debutM1,$finP1,$sexe);
    #
    my $idKaldi_M1=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debut,$finM1,$sexe);
    my $idfile_M1=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debut,$finM1,$sexe);
    #my $idKaldi_M1=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debut,$finM1,$sexe);
    #my $idfile_M1=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debut,$finM1,$sexe);

    my $idKaldi__=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debut,$fin,$sexe);
    my $idfile__=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debut,$fin,$sexe);

    #my $idKaldi__=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debut,$fin,$sexe);
    #my $idfile__=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debut,$fin,$sexe);

    my $idKaldi_P1=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debut,$finP1,$sexe);
    my $idfile_P1=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debut,$finP1,$sexe);

    #my $idKaldi_P1=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debut,$finP1,$sexe);
    #my $idfile_P1=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debut,$finP1,$sexe);


    my $idKaldiP1M1=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debutP1,$finP1,$sexe);
    my $idfileP1M1=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debutP1,$finP1,$sexe);

    #my $idKaldiP1M1=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debutP1,$finM1,$sexe);
    #my $idfileP1M1=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debutP1,$finM1,$sexe);

    my $idKaldiP1_=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debutP1,$fin,$sexe);
    my $idfileP1_=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debutP1,$fin,$sexe);

    #my $idKaldiP1_=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debutP1,$fin,$sexe);
    #my $idfileP1_=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debutP1,$fin,$sexe);


    my $idKaldiP1P1=sprintf ("$rep1/%s\\#%s%07d\\#%07d:%07d\\#%s.lat.gz",$showKaldi, $sexe,$num,$debutP1,$finP1,$sexe);
    my $idfileP1P1=sprintf ("$rep1/%s#%s%07d#%07d:%07d#%s.lat.gz",$showKaldi, $sexe,$num,$debutP1,$finP1,$sexe);

    #my $idKaldiP1P1=sprintf ("$rep1/S%s%07d\\#%s\\#%07d:%07d\\#%s.lat.gz", $sexe,$num,$showKaldi,$debutP1,$finP1,$sexe);
    #my $idfileP1P1=sprintf ("$rep1/S%s%07d#%s#%07d:%07d#%s.lat.gz", $sexe,$num,$showKaldi,$debutP1,$finP1,$sexe);

    my $idSph= "$repOut/".join("-",@res[0,2..4]).".lat.gz";
    #print("$idfileM1M1 $idKaldiM1M1 $idSph\n");
    if (-f "$idfileM1M1") {
      print "ln -s   $idKaldiM1M1  $idSph\n";
      #`ln -s   $idKaldiM1M1  $idSph\n`;
    }
    if (-f "$idfileM1_") {
      print "ln -s   $idKaldiM1_  $idSph\n";
      #`ln -s   $idKaldiM1_  $idSph\n`;
    }
    if (-f "$idfileM1P1") {
      print "ln -s   $idKaldiM1P1  $idSph\n";
      #`ln -s   $idKaldiM1P1  $idSph\n`;
    }
    if (-f "$idfile_M1") {
      print "ln -s   $idKaldi_M1  $idSph\n";
      #`ln -s   $idKaldi_M1  $idSph\n`;
    }
    if (-f "$idfile__") {
      print "ln -s   $idKaldi__  $idSph\n";
      #`ln -s   $idKaldi__  $idSph\n`;
    }
    if (-f "$idfile_P1") {
      print "ln -s   $idKaldi_P1  $idSph\n";
      #`ln -s   $idKaldi_P1  $idSph\n`;
    }
    if (-f "$idfileP1M1") {
      print "ln -s   $idKaldiP1M1  $idSph\n";
      #`ln -s   $idKaldiP1M1  $idSph\n`;
    }
    if (-f "$idfileP1_") {
      print "ln -s   $idKaldiP1_  $idSph\n";
      #`ln -s   $idKaldiP1_  $idSph\n`;
    }
    if (-f "$idfileP1P1") {
      print "ln -s   $idKaldiP1P1  $idSph\n";
      #`ln -s   $idKaldiP1P1  $idSph\n`;
    }
}
