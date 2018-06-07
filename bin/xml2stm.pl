#!/usr/bin/perl

if(scalar(@ARGV) != 1){
	die "Usage $0 fichierXML\n";	
}

$fic = $ARGV[0];

$show = "";
$toWrite = "";
$vert = "#006400";
$orange = "#FFA500";
$rouge = "#DC143C";

open(FIC, $fic) || die "Impossible d'ouvrir $fic\n";
while($ligne = <FIC>){
	if($ligne =~ /<word sel\=\"([^\"]+)\" start\=\"([^\"]+)\" length\=\"([^\"]+)\" scoreConfiance\=\"([^\"]+)\"/){
		$toWrite .= $1." ";
	}elsif($ligne =~ /<sentence start\=\"([^\"]+)\" end\=\"([^\"]+)\" locuteur\=\"([^\"]+)\" type\=\"([^\"]+)\" sexe\=\"([^\"]+)\"/){
		if($4 eq "Studio"){
			$type = "f0";
		}else{
			$type = "f3";
		}
		$toWrite = "$show 1 $3 $1 $2 <o,$type,".lc($5)."> ";
	}elsif($ligne =~ /<\/sentence/){
		print $toWrite."\n";
	}elsif($ligne =~ /<show name=\"([^\"]+)\"/){
		$show = $1;
	}
	
}
close(FIC);
