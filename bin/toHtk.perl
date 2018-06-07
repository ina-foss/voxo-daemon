#!/usr/bin/perl -w
use strict;

my @nodes;
my @nodesSup;
my $name="";
my $final=-1;
my @numero;
my $valeurMin=0;
sub decompresse() {
    @numero=();
    my @newNodes=();


#je renumerote les noeuds et je mets les arcs avec le bon noeud pour les numeros qui avaiy plusieurs mots, restera  a dupliquer les arcs
{    my ($i,$newI)=(0,0);
    foreach my $n (@nodes) {
	$numero[$i]=$newI;



	$n->{W}=$n->{LW}[0];
	#print STDERR "$i  $newI: $nodes[$i]->{W} ";
	#    print STDERR "$nodes[$i]->{T}\n";
	($nodes[$i]->{T} >=0) or print STDERR "$i $newI $name\n" ;


	$i++;
	$newI+=$#{$n->{LW}}+1;
    }
     $final=$numero[$final];
    push @numero,$newI; 
   $newNodes[$newI-1]=-1;
}

    for (my ($iNode,$newI)=(0,0); $iNode<=$#nodes;$iNode++ ) {
	my $n=$nodes[$iNode];
	my @edge=@{$n->{E}};
	if ($#{$n->{LW}} == 0 ) {
	    $newNodes[$newI]=$n;
	    foreach  my $ed (@edge) {
		$ed->{S}=$newI;
	    }
	    $newI++;
	    next;
	}

	for (my ($j,$e)=(0,0); $j<=$#{$n->{LW}}; $j++) {

	    my $motCourant=$n->{LW}->[$j];
	    $newNodes[$newI]={T=>$n->{T},W=> $motCourant};
#	    print STDERR "$iNode $j  $newI: $newNodes[$newI]->{W} $motCourant";
#	    print STDERR "$newNodes[$newI]->{T}\n";

 	    while ($e<=$#edge && $edge[$e]->{W} eq $motCourant) {
		$edge[$e]->{S}=$newI; # c'est celui le nouveau depart;
		push @{$newNodes[$newI]->{E}}, $edge[$e];
		$e++;
	    }

	    $newI++;

	}
    }
    @nodes=@newNodes;

}
sub parcours() {
    my @pile=(0);
    $nodes[0]->{T}=0;
    while ($#pile>=0) {
	my $ind=pop @pile;
	my $n=$nodes[$ind];
	$n->{T}>=0 or die "bizarre parcours";
	 foreach my  $edge ( @{$n->{E}}) {
             if($ind <=-1) {
		 print STDERR "$name $ind $edge->{E}\n";

	     }
	     my $fils=$nodes[$edge->{E}];
	     my $d=$edge->{D};
	     $edge->{AC} -= $d*$valeurMin;
	     my $t=$d+$n->{T};
	     if ($fils->{T}<0) {
		 $fils->{T}=$t;
		 push @pile,$edge->{E};
		 next;
	     }
	     next if ($t == $fils->{T});
	     print STDERR  "bizarre $ind $edge->{E} $edge->{S} $t $fils->{T}\n";
		 
	     
	 }

    }
}
sub faireGraphe() {
    parcours();
    decompresse();
    #print STDERR "$name -> $valeurMin\n";
    $valeurMin=0;
    open FILE, "| gzip >$name.lat.gz";

    print FILE "#$name\n";
    printf  FILE "start=%d end=%d\n",0,$final;
    for (my $index=0 ; $index<= $#nodes ; $index++)  {
	my $v=$nodes[$index];
	printf FILE "I=%s\tt=%.2f\tW=%s\tv=1\n",$index,($v->{T})/100,$v->{W};
    }
    my $nEdge=0;
    for (my $index=0 ; $index<= $#nodes ; $index++)  {
	my $v=$nodes[$index];


	foreach my  $edge ( @{$v->{E}}) {
	    for (my $v=$numero[$edge->{E}]; $v <$numero[$edge->{E}+1] ; $v++) {
		printf FILE "J=%d\tS=%s\tE=%d\ta=%s\tl=%s\n",$nEdge++,$edge->{S},$v,-$edge->{AC},-$edge->{LM};
	    }
	}
    }
    printf FILE "N=%d L=%d\n",$#nodes+1,$nEdge;
    close FILE;
    @nodes=();
    @nodesSup=();
    $final=-1;

}
my $motCourant="" ;
push @nodes, {W=>"" , T=> -1, E=>[],F=> 1, LW=>["<s>"]};
push @{$nodes[$#nodes]->{E}},{S=>0 ,E=>1,AC=>0,LM=>0,D=>0};
while (<>) {
    if	(/^\s*$/) {
	faireGraphe() if ($name ne "") ;
	push @nodes, {W=>"" , T=> -1, E=>[],F=> 1, LW=>["<s>"]};
	push @{$nodes[$#nodes]->{E}},{S=>0 ,E=>1,AC=>0,LM=>0,D=>0};

	$name="";
	next;
	
    }
    my @l=split;
    
    if ($#l==0) {
	if ($name eq "") {
	    $name=$l[0];
	    next;}
	else {
	    push @nodes,  {LW=> ["</s>"] , T=> -1, E=>[],F=>1};
	    $final=$#nodes;
	    next;
	}
    }
    if ($#nodes != $l[0]+1) {
	$motCourant =$l[2];
	push @nodes, {W=>"" , T=> -1, E=>[],F=> 1, LW=>[$l[2]]};
    }
    if ($motCourant ne $l[2])
    { push @{$nodes[$#nodes]->{LW}},$l[2];
      $motCourant =$l[2];}
    
    
    my    ($lm,$ac,$d)=split(',',$l[3]);
    if ($d>0) {
	my $toto=$ac/$d;
	$valeurMin=$toto if ($toto<$valeurMin);
    }
    push @{$nodes[$#nodes]->{E}},{W=>$l[2],S=>$l[0]+1,E=>$l[1]+1,AC=>$ac,LM=>$lm,D=>$d};
}



	
