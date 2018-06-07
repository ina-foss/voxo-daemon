#!/usr/bin/perl -w
use strict;
my $rep=$ARGV[0];
my $sphFile=$ARGV[1];
my $sph2pipe=$ARGV[2];
my $rate=sprintf("%.2f",$ARGV[3]);
open (CTL,">$rep/segments") or die "pas ouvert CTL\n";
open (TRANS,">$rep/text") or die "pas ouvert TRANS\n";
open (UTT,">$rep/utt2spk") or die "pas ouvert UTT\n";
open (WAV,">$rep/wav.scp") or die "pas ouvert SCP\n";
my  %longueur;
my %vuWav;

while (<STDIN>) {

    my @res = /\S+/g;
    if (! defined($longueur{$res[0]})) {
        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($sphFile);
        print STDERR "[02kaldi.perl] $sphFile\n" unless (defined ($dev));
    #	print STDERR "$dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks\n" if (defined($dev));
        $longueur{$res[0]}=sprintf("%.2f",((($size -1024)/2) -320)/$rate);
        print STDERR "[02kaldi.perl] Treating show '$res[0]', detected time $longueur{$res[0]}\n";
    }
    my $tailleMax=$longueur{$res[0]};
    $res[3] =($res[3]>$tailleMax) ? $tailleMax : $res[3];
    my $debut =  $res[2]*100;
    my $fin =    $res[3]*100-1;
    next if ($fin-$debut >10000 );
    $debut = ($debut <0) ? 0: $debut;

    my @loc=split ('-',$res[4]);
    my ($sexe) = $loc[0]=~/(.)$/;
    my ($num)= $loc[1]=~ /S(\d+)/;
    printf CTL "%s#%s%07d#%07d:%07d#%s %s %.2f %.2f\n",$res[0], $sexe,$num,$debut,$fin,$sexe,$res[0], $res[2],$res[3]; 
    printf TRANS "%s#%s%07d#%07d:%07d#%s %s\n", $res[0],$sexe,$num,$debut,$fin,$sexe,join(' ',@res[5..$#res]);
    printf UTT  "%s#%s%07d#%07d:%07d#%s %s#%s%07d\n",$res[0],$sexe,$num,$debut,$fin,$sexe,$res[0],$sexe,$num;
    printf WAV "%s %s -c 1 -f wav -p  %s|\n",$res[0],$sph2pipe, $sphFile unless (defined($vuWav{$res[0]}));
    $vuWav{$res[0]}=1;
}
close(CTL);
close(TRANS);
close(UTT);
close(WAV);
