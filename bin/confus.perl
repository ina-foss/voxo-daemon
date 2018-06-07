#!/usr/bin/perl -w
use strict;
use locale;
use POSIX qw(locale_h);
setlocale(LC_CTYPE,"ISO-8859-1");
my $repertoire=$ARGV[0];
shift;
#my $commande = "find $repertoire" .' -name "*saus" | tr "-" " " | sort -k 1,1 -k 2n,2 | tr " " "-"|';
my $commande = "find $repertoire" .' -name "*saus" |';
#print STDERR $commande ."\n";


my $elag=0.0;
if ($#ARGV >=0) {
    $elag =$ARGV[0];
    shift;
}
open PIPE,$commande or die "pas ouvert:$commande\n";
my @fich=<PIPE>;
my @analyse;

close PIPE;
foreach my $ligne (@fich) {
    chomp $ligne;
    my ($rac,$nom,$debut,$fin)= $ligne=~m%(\S*/)([^-]+)-([^-]+)(.*)%;
    push @analyse , [$rac,$nom,$debut,$fin];
}
my @tri;
@tri =sort {2*($a->[1] cmp $b->[1]) + ($a->[2] <=> $b->[2])} @analyse;
foreach my $val (@tri) {
    my ($rac,$fich,$debut,$fin)= @{$val};
    my $nom="$rac/$fich-$debut$fin";
#    print  $nom. "\n" ;
#    next;
    
    open SAUS,$nom or die "pas ouvert |$nom|\n";
    $nom =~ s%^.*/%%;
    $nom =~s/saus$//;
    my @info=split('-',$nom);
    my $anc="";
    my ($temps,$temps1)=(-10.,-10.);
    while (<SAUS>) {
	chomp;
	if (/timestamp/ ) {
	    my @v1=split (/\s+/,$anc);
	    my @v2=split;
#	    $v1[3] =0.90 if ($v1[3]>0.90);
	    if ($v1[2] ne "eps"  ) {
		$temps=$v2[3]+$v2[4];
#		print STDERR "probleme $nom $temps $temps1 $v1[2]\n" if ($temps<=$temps1 && $v1[2] !~/\[|</);
		$temps=$temps1+2 if ($temps<=$temps1);
		$temps1=$temps if ($v1[2] !~/\[|<|_filler_/);

        # Don't print fillers
        print join(' ',$info[0],1,$info[1]+($temps)/200, 0.02,$v1[2],$v1[3] #,1,$nom)
        	   )."\n" if ($v1[2] !~ /(<.*>)|(\[.*\])|_filler_/  && $v1[3]>=$elag) ;
        }

        # Print fillers
        #print join(' ',$info[0],1,$info[1]+($temps)/200, 0.02,$v1[2],$v1[3] #,1,$nom)
        #	   )."\n" if ($v1[2] !~ /(\[.*\])|_filler_/  && $v1[3]>=$elag) ;
        #}
	}
	$anc=$_ unless ($anc ne "" && /<s>/);

#	$anc=$_;
    }
}
