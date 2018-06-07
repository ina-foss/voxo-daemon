#!/usr/bin/perl -w


if ($#ARGV!=1) {
  print STDERR "Usage: $0 seg ctm > out\n";
  exit;
}

open (FSEG, "$ARGV[0]") || die "can't open $ARGV[0]\n";
open (FCTM, "$ARGV[1]") || die "can't open $ARGV[1]\n";

@iSeg=();
@dSeg=();
@fSeg=();
$first=1;
$nbSeg=0;
while (<FSEG>) {
  if ( (/^;;/)) {
    next;
  }
  
  @item = split;
	if($item[5] eq 'S') {
		$chan='f0';
	} else {
		$chan='f3';
	}
	
	if($item[4] eq 'M') {
		$gender='male';
	} else {
		$gender='female';
	}
		
  $infoSeg="$item[0] $item[1] $item[7] " . ($item[2]/100) . " " . (($item[2]+$item[3])/100) . " <o,$chan,$gender>";

  #$infoSeg = "$item[0] $item[1] $item[2] $item[3] $item[4] $item[5]";
  $iSeg[$nbSeg] = $infoSeg;
  $dSeg[$nbSeg] = $item[2]/100;
  $fSeg[$nbSeg++] = ($item[2]+$item[3])/100;
}

$lastSeg=0;

while (<FCTM>) {
  @item = split;
#  $deb = $item[2];
  $milieu = $item[2] + $item[3]/2;
  $mot = $item[4];
  
#	print "($milieu >= $dSeg[$lastSeg]) && ($milieu <= $fSeg[$lastSeg])\n";

  if ( ($milieu >= $dSeg[$lastSeg]) && ($milieu <= $fSeg[$lastSeg]) ) {
#	print "On va afficher le mot\n";
	
    if ($first) {
      print "$iSeg[$lastSeg]";
      $first=0;
    }
   
    print " $mot";
  }
  else {
    while ( ($milieu > $fSeg[$lastSeg]) && ($lastSeg<$nbSeg) ) { $lastSeg++; }
    if ( ($milieu >= $dSeg[$lastSeg]) && ($milieu <= $fSeg[$lastSeg]) ) {
      print "\n$iSeg[$lastSeg] $mot";
    }
  }
}
  
  
