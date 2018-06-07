#!/usr/bin/perl -w
use locale;
use POSIX qw(locale_h);
setlocale(LC_CTYPE,"ISO-8859-1");
if(scalar(@ARGV) != 2){
		print "Usage : $0 repertoireSaucisses fichierSeg\n";
		exit;
}
my $repertoire=$ARGV[0];
my $ficSeg = $ARGV[1];
shift;



my @infoTemps = ();
putTimesIntoMemory($ficSeg, \@infosTemps);


my $commande = "find $repertoire" .' -name "*saus" | tr "-" " " | sort -k 1,1 -k 2n,2 | tr " " "-"|';
print STDERR $commande ."\n";

my $writeHeader = 0;
my $sentence = "";
my $show = "";
my %table = ();
my $elag=0.0;
if ($#ARGV >=0) {
    $elag =$ARGV[0];
    shift;
}
open PIPE,$commande or die "pas ouvert $commande"; 
while (<PIPE>) {
    my $nom = $_;
    chomp($nom);
    open(SAUS, $nom) || die "pas ouvert $nom\n";
    $nom =~ s%^.*/%%;
    $nom =~s/saus$//;
    my @seg=split('-',$nom);
    if(!$writeHeader){
    	$show = $seg[0];
    	print "<?xml version='1.0' encoding='ISO-8859-1'?>\n";
    	print "<show name=\"$show\">\n";
    	$writeHeader = 1;
    }
    my $ligne = "";
    $sentence = "";
    while($ligne = <SAUS>){
    	chomp($ligne);
    	my @infos = split(/\s+/,$ligne);
    	if(scalar(@infos) > 3){
	    	my $mot = $infos[2];
	    	if($mot ne "timestamp"){
	    		my $sc = $infos[3];
	    		$table{$sc."_".$mot} = $mot;
	    	}else{
	    		my $tpsDeb = $infos[3]/100;
	    		my $tpsFin = $infos[4]/100;
	    		my $startSeg = $seg[1];
	    		my $endSeg = $seg[2];
	    		my @tab = sort sortKey keys(%table);
	    		if(scalar(@tab) > 0){
	    			if($tab[0] =~ /([^\_]+)\_(\S+)/){
			    		my $wordSel = $2;
					$wordSel =~ s/\&/_et_/g;	
			    		my $scoreSel = $1;
			    		if( ($wordSel ne "eps") && ($wordSel ne "euh") && ($wordSel !~ /\</) && ($wordSel !~ /\[/) ){
			    			$sentence .= "<word sel=\"$wordSel\" start=\"".($startSeg+$tpsDeb)."\" length=\"".($tpsFin-$tpsDeb)."\" score=\"$scoreSel\">\n";
				    		foreach(@tab){
				    			my $cle = $_;
				    			if($cle =~ /([^\_]+)\_(\S+)/){
								my $prop=$2;
								$prop =~ s/\&/_et_/g;
				    				if( ($prop ne "eps") && ($prop !~ /\</) && ($prop !~ /\[/) ){
				    					$sentence .= "<prop mot=\"$2\" scoreProp=\"$1\"/>\n";
				    				}
				 				 }	
				    		}
				    		$sentence .= "</word>\n";
			    		}
	    			}
	    		}

	    		%table = ();
	    	}
	    	
    	}
    }
    %table = ();
    if(length($sentence)>0){
    	my @infoBande = split(/\_/, $seg[3]);
    	my $type = "phone";
    	if(lc($infoBande[0]) eq "f0"){
    		$type = "studio";
    	}
    	my $sexe = "female";
    	if(lc($infoBande[1]) eq "m"){
    		$sexe = "male";
    	}
    	my $monTimePourRecherche = ($seg[1]+(($seg[2]-$seg[1])/2))*100;
    	my $monLocuteurCluster = rechercheLocuteur($monTimePourRecherche,$show,\@infoTemps);
    	if($monLocuteurCluster eq "-1"){
	    	print "<sentence start=\"".$seg[1]."\" end=\"".$seg[2]."\" speaker=\"".$seg[4]."\" type=\"$type\" gender=\"$sexe\">\n";
	    	print $sentence;
	    	print "</sentence>\n";
    	}else{
    		my @infosMonLoc = split(/\-/, $monLocuteurCluster);
    		$monLocuteurCluster = $infosMonLoc[0];
    		if($infosMonLoc[1] eq "M"){
    			$sexe = "male";	
    		}else{
    			$sexe = "female";
    		}
    		if($infosMonLoc[2] eq "S"){
    			$type = "studio";	
    		}else{
    			$type = "phone";
    		}
    		print "<sentence start=\"".$seg[1]."\" end=\"".$seg[2]."\" speaker=\"".$monLocuteurCluster."\" type=\"$type\" gender=\"$sexe\">\n";
	    	print $sentence;
	    	print "</sentence>\n";
	    }
    }    
    close(SAUS);
}

if($writeHeader){
	print "</show>\n";	
}

sub sortKey{
	my $scA = 0;
	my $scB = 0;
	if($a =~ /([^\_]+)\_(\S+)/){
		$scA = $1;	
		if($b =~ /([^\_]+)\_(\S+)/){
			$scB = $1;
			return $scB <=> $scA;
		}
	}
	return $b cmp $a;
}

sub rechercheLocuteur{
	my $temps = $_[0];
	my $show = $_[1];
	my $refTable = $_[2];
	my $deb;
	my $fin;
	my @infos = ();
	foreach(@refTable){
		@infos = split(/\-/, $_);
		if( ($temps>=$infos[1]) && ($temps <= $infos[2]) && ($show eq $infos[0])){
			#nom-type-bande
			return "$infos[5]-$infos[3]-$infos[4]";
		}
	}
	return "-1";
}


sub putTimesIntoMemory{
	my $fichier = $_[0];
	my $refTable = $_[1];
	return 0 if(!(-e $fichier));
	my $cmd = "cat $fichier";
	my @out = `$cmd`;
	my $ligne = "";
	my @infos = ();
	
	foreach(@out){
		$ligne = $_;
		chomp($ligne);
		if($ligne !~ /^;;/){
			@infos = split(/ /,$ligne);
			if(scalar(@infos) == 8){
				#show-debut-fin-type(M ou F)-S ou T-nomLoc
				push(@refTable, $infos[0]."-".$infos[2]."-".($infos[3]+$infos[2])."-".$infos[4]."-".$infos[5]."-".$infos[7]);	
			}
		}
	}
	return 1;
}
