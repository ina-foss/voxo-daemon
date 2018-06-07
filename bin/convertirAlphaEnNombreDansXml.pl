#!/usr/bin/perl
use Encode qw(decode encode);

if(scalar(@ARGV) != 1){
	die "Usage : $0 fichierXML\n";
}

$xml = $ARGV[0];

@words = ();
$bigCHAINE = "";
$entete="";
$lastBigCHAINE = "";
$isInHead = 1;


my %num_table;
my %num_alpha;

initNumberTab();

#Retourner table num_table;
foreach(sort keys %num_table){
	$nombre = $_;
	$alpha = $num_table{$nombre};
	$num_alpha{$alpha}=$nombre;
	if($alpha =~ /e$/){
		$ch = $alpha;
		chop($ch);
		$ch .= "ième";
		$num_alpha{$ch} = $nombre;
	}else{
		$ch = $alpha;
		$ch .= "ième";
		$num_alpha{$ch}=$nombre;
	}
}
$num_alpha{"cinquième"}=5;
$num_alpha{"neuvième"}=9;

$ch = "";
open(FIC, $xml);
while($ligne = <FIC>){
	chomp($ligne);
	if($ligne =~ /<[\/]?sentence/ || $ligne =~ /<[\/]show/){
		$isInHead = 0;
		push(@words, $ligne);
	}
	if($ligne =~ /<word/){
		$ch = "";
	}
	if($isInHead){
		$entete .= $ligne."\n";
	}
	$ch .= $ligne."\n";
	if($ligne =~ /<\/word/){
		push(@words, $ch);
	}
}
close(FIC);



print $entete;
for($i=0; $i<scalar(@words); $i++){
	$monMot = $words[$i];
	$chaine = "";
	$currI = $i;
	$mPonct = "";
	if($monMot =~ /<word sel=\"(.*)\" start(.*)/){	
		$mM = $1;
		if(endWithPonct($mM)){
			$mPonct=$poncc;
			chop($mM);
		}
		$bOk = 0;
		if($mM =~ /-/){
			$bOk = 1;
			@iii = split(/-/, $mM);
			foreach(@iii){
				if(!exists($num_alpha{$_})){
					$bOk = 0;
				}
			}
		}

        # Ou le mot est un nombre en toutes lettres
        # Ou alors c'est une suite de nombre en toutes lettres
        # séparés par des - ($bOk == 1)
		if(exists($num_alpha{lc($mM)}) || $bOk){
            # On va constituer la chaîne à donner au parser
            # On prend la plus grande chaîne constituée d'une suite
            # de nombres
			$chaine .= lc($mM)."-";	
			@fus = ();
            # On sauvegarde l'index courant
			push(@fus, $i);
			$end=0;
			while(!$end){
                # On vérifie qu'on est pas à la fin de la liste
                # des mots
				if($i+1 < scalar(@words)){
					$nextWords = $words[$i+1];
					$mPonctN="";
                    # Si le prochain mot est bien un mot
					if($nextWords =~ /<word sel=\"(.*)\" start(.*)/){
                        $mM = $1;
                        if(endWithPonct($mM)){
                            $mPonctN=$poncc;
                            chop($mM);
                        }
                        $bOk = 0;
                        if($mM =~ /-/){
                            $bOk = 1;
                            @iii = split(/-/, $mM);
                            foreach(@iii){
                                if(!exists($num_alpha{$_})){
                                    $bOk = 0;
                                }
                            }
                        }

                        # Ou le prochain mot est un nombre en toutes lettres
                        # Ou alors c'est une suite de nombre en toutes lettres
                        # séparés par des - ($bOk == 1)
						if(exists($num_alpha{lc($mM)}) || $bOk){
							$mPonct=$mPonctN;
							$chaine .= lc($mM)."-";
							$i++;
							push(@fus, $i);
						}else{
						# Sinon on sort de la boucle
							$end = 1;
						}
					}else{
						$end = 1;
					}
				}else{
					$end = 1;
				}
			}
            # On enlève le dernier - qu'on avait rajouté à chaque fois
			chop($chaine);
            # On récupère l'index du premier mot et du dernier mot trouvés
			$firstWord = $words[$fus[0]];
			$lastWord = $words[$fus[scalar(@fus)-1]];

			if($firstWord =~ /\<word sel=\"(.*)\" start=\"(.*)\" length=\"(.*)\" scoreConfiance=\"(.*)\"/){
				$start = $2;
				$score = $4;
			}
			if($lastWord =~ /\<word sel=\"(.*)\" start=\"(.*)\" length=\"(.*)\" scoreConfiance=\"(.*)\"/){
				$length = ($2+$3)-$start;
			}	
			if(chaineIsWellFormed($chaine)){	

			    $chaine = alphaToNumber($chaine);

				if($chaine !~ /ERROR/){
					print "<word sel=\"$chaine".$mPonct."\" start=\"$start\" length=\"$length\" scoreConfiance=\"$score\">\n";
					print "<prop mot=\"$chaine".$mPonct."\" scoreProp=\"1.00\"/>\n";
					print "</word>\n";
				}else{
					print $monMot;
                    $i = $currI;
				}
			}else{
				print $monMot;
				$i = $currI;
			}
		}else{
			print $monMot;
		}
	}else{
		print $monMot."\n";
	}

}

#print "</show>\n";

sub alphaToNumber{
	my $chaine = $_[0];

    $chaineAlpha = $chaine;
    $cmd = "./convertirAlphaEnNombre.pl $chaine";
    $oCmd = `$cmd`;
    chomp($oCmd);
    $chaine = $oCmd;

    #Je regarde si je retrouve pareil en convertissant alpha en nombre...
    if($chaine !~ /ème/){
        $cmd = "./convertirNombreEnAlpha.pl $chaine";
        $oCmd = `$cmd`;
        chomp($oCmd);
        $chNb = decode('UTF-8', $oCmd);
    
        if($chNb ne $chaineAlpha){
            $chaine = "ERROR";
        }
    }
    
    return $chaine;

}
sub chaineIsWellFormed{
	my $chaine = $_[0];
	if(lc($chaine) eq "un" || lc($chaine) eq "virgule"){
		return 0;
	}
	return 1;
}

sub endWithPonct{
	my $word = $_[0];
	my @marqs = ();
	push(@marqs, ".");
	push(@marqs, ",");
	push(@marqs, "?");
	push(@marqs, "!");
	push(@margs, ";");
	my $last = chop($word);
	
	foreach(@marqs){
		if($last eq $_){
			$poncc = $_;
			return 1;
		}
	}
	return 0;
}

sub initNumberTab{
    %num_table=("0"=>"zéro",
                "1"=>"un",
                "2"=>"deux",
                "3"=>"trois",
                "4"=>"quatre",
                "5"=>"cinq",
                "6"=>"six",
                "7"=>"sept",
                "8"=>"huit",
                "9"=>"neuf",
                "10"=>"dix",
                "11"=>"onze",
                "12"=>"douze",
                "13"=>"treize",
                "14"=>"quatorze",
                "15"=>"quinze",
                "16"=>"seize",
                "20"=>"vingt",
                "21"=>"vingt-et-un",
                "30"=>"trente",
                "31"=>"trente-et-un",
                "40"=>"quarante",
                "41"=>"quarante-et-un",
                "50"=>"cinquante",
                "51"=>"cinquante-et-un",
                "60"=>"soixante",
                "70"=>"soixante-dix",
                "71"=>"soixante-et-onze",
                "72"=>"soixante-douze",
                "73"=>"soixante-treize",
                "74"=>"soixante-quatorze",
                "75"=>"soixante-quinze",
                "76"=>"soixante-seize",
                "77"=>"soixante-dix-sept",
                "78"=>"soixante-dix-huit",
                "79"=>"soixante-dix-neuf",
                "80"=>"quatre-vingt",
                "90"=>"quatre-vingt-dix",
                "91"=>"quatre-vingt-onze",
                "92"=>"quatre-vingt-douze",
                "93"=>"quatre-vingt-treize",
                "94"=>"quatre-vingt-quatorze",
                "95"=>"quatre-vingt-quinze",
                "96"=>"quatre-vingt-seize",
                "97"=>"quatre-vingt-dix-sept",
                "98"=>"quatre-vingt-dix-huit",
                "99"=>"quatre-vingt-dix-neuf",
		"1000"=>"mille",
		"100"=>"cent",
		"1000000"=>"million",
		"1000000000"=>"milliard",
		"1001"=>"milles",
                "101"=>"cents",
                "1000001"=>"millions",
                "1000000001"=>"milliards",
		"1111"=>"virgule");
    
}
