#!/usr/bin/perl


if(scalar(@ARGV) != 2){
	print "Usage : $0 fichierCtm repertoireSaucisses\n";	
	exit;
}


$ctm = $ARGV[0];
$repSauc = $ARGV[1];

@infoTemps = ();
putTimesIntoMemory($repSauc, \@infosTemps);

open(CTM, $ctm) || die "Impossible d'ouvrir $ctm\n";

$lastInfoTemps = "";
$toPrint = "init";
while($ligne = <CTM>){
	chomp($ligne);
	@infos = split(/ /, $ligne);
	$show = $infos[0];
	$time = $infos[2];
	$mot = $infos[4];
	$infoTemps = rechercheTimes($time,$show,\@infoTemps);
	if($infoTemps ne "-1"){
		if($toPrint eq "init"){
			@tmp = split(/\-/, $infoTemps);
			$tmp = "$tmp[0] $tmp[1]";
			$loc = $tmp[3];
			$loc =~ s/saus//g;
			$type = $tmp[2];
			@infoType = split(/\_/, $type);
			$bande = lc($infoType[0]);
			if($infoType[1] eq "M"){
				$sexe = "male";
			}else{
				$sexe = "female";	
			}
			$toPrint = 	"$show 1 $loc $tmp <o,$bande,$sexe>";
			$lastInfoTemps = $infoTemps;
		}
		if($infoTemps ne $lastInfoTemps){
			print $toPrint."\n";
			$lastInfoTemps = $infoTemps;
			@tmp = split(/\-/, $infoTemps);
			$tmp = "$tmp[0] $tmp[1]";
			$loc = $tmp[3];
			$loc =~ s/saus//g;
			$type = $tmp[2];
			@infoType = split(/\_/, $type);
			$bande = lc($infoType[0]);
			if($infoType[1] eq "M"){
				$sexe = "male";
			}else{
				$sexe = "female";	
			}
			$toPrint = "$show 1 $loc $tmp <o,$bande,$sexe> $mot";
		}else{
			$toPrint .= " $mot";
		}
	}else{
		print "ERREUR !! IMPOSSIBLE DE TROUVER LE TEMPS POUR $ligne\n";
		exit;	
	}
}
	
close(CTM);
print $toPrint."\n";

sub rechercheTimes{
	my $temps = $_[0];
	my $show = $_[1];
	my $refTable = $_[2];
	my $deb;
	my $fin;
	my @infos = ();
	foreach(@refTable){
		@infos = split(/\-/, $_);
		if( ($temps>=$infos[0]) && ($temps <= $infos[1]) && ($show eq $infos[2])){
			return "$infos[0]-$infos[1]-$infos[3]-$infos[4]";
		}
	}
	return "-1";
}


sub putTimesIntoMemory{
	my $rep = $_[0];
	my $refTable = $_[1];
	my $cmd = "cd $rep;ls *saus";
	my @out = `$cmd`;
	my $ligne = "";
	my @infos = ();
	
	foreach(@out){
		$ligne = $_;
		chomp($ligne);
		@infos = split(/\-/,$ligne);
		if(scalar(@infos) == 5){
			push(@refTable, $infos[1]."-".$infos[2]."-".$infos[0]."-".$infos[3]."-".$infos[4]);	
		}	
	}
}


