#!/usr/bin/perl

if(scalar(@ARGV) != 2){
	die "Usage : $0 fichierXml fichierCTMMaj\n";
}

$xml = $ARGV[0];
$ctm = $ARGV[1];

$nbMots = 0;
$chaine = "";

@tabCTM = (); #temps#mot
putCTMIntoMem($ctm);

open(XML, $xml) || die "impossible d'ouvrir $xml\n";
while($ligne = <XML>){
	chomp($ligne);
	if($ligne =~ /\<word sel=\"([^\"]*)\" start=\"([^\"]*)\"(.*)/){
		$mot = $1;
		$start = $2;
		$reste = $3;
				
		@tabMots = ();
		donneLesMots($start-1, $start+1);
		foreach(@tabMots){
			if(getLC($_) eq getLC($mot)){
				$mot = $_;
			}
		}

		print "<word sel=\"$mot\" start=\"$start\"$reste\n"; 
		
	}else{
		print $ligne."\n";
	}
}
close(XML);



sub getLC{
    my $nomPropre = $_[0];
    $nomPropre = lc($nomPropre);
    $newChaine = "";
    for($i=0;$i<length($nomPropre);$i++){
	$char = substr($nomPropre,$i,1);
	if((ord($char)>=192) && ((ord($char))<=222)){ #é maj en é min
	    $char = chr(ord($char)+32);
	}
	$newChaine = $newChaine.$char;
    }
    return $newChaine;
}


sub donneLesMots{
	my $timeFrom=$_[0];
	my $timeTo=$_[1];
	@tabMots = ();
	foreach(@tabCTM){
		@infos = split(/#/, $_);
		$tps = $infos[0];
		if($tps >= $timeFrom && $tps <= $timeTo){
			push(@tabMots, $infos[1]);
		}elsif(scalar(@tabMots)>0){
			return;
		}
	}
	return;
}

sub putCTMIntoMem{
	my $ctm = $_[0];
	my $cmd = "cat $ctm | grep -v \" euh \" | grep -v \" \\[\" | grep -v \" \<\"";
	my @oCmd = `$cmd`;
	foreach(@oCmd){
		@infos = split(/ +/, $_);
		push(@tabCTM, $infos[2]."#".$infos[4]);		
	}
}
