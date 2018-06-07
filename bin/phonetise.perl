#!/usr/bin/perl -w

use strict;
my $compact=1;
open TABLE,$ARGV[0] or die "pas ouvert $ARGV[0]\n" ;
shift;
$compact = shift @ARGV if ($#ARGV >=0);
my @table;
while (<TABLE>) {
my ($nom) = /([^ _]+)/;
push @table,$nom;
}
my %filler=split(' ',"+sil+ <sil> +i+ [i]");

while(<>) {

    my @l=split;
    if ($#l<3) {
	print;
	next;
    }
    my ($ac,$lm,$ph)= split(',',$l[3]);
    my @ph=split('_',$ph);
    my @res;
    if ($compact ) { 
	$#ph==1 or die "bizarre $_";
#   $ph=join('_',$table[$ph[0]],$ph[1]);
	$ph=join('_',$ph[1]);
	$l[2]="<eps>" if ($l[2] eq "<unk>");
	if ($l[2] eq "<eps>"){
	    $l[2] = $table[$ph[0]];
	    if (defined($filler{$l[2]})) {
		$l[2]=$filler{$l[2]};}
	    else {
		$l[2]="[b]";
	    }

	}
    }
    
    else
    {
    foreach my $v (@ph) {
	push @res,$table[$v];
    }
    $ph=join('_',@res);
    }
    $l[3]="$ac,$lm,$ph";
    print join(' ',@l) ."\n";
}
