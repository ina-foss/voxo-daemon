#!/usr/bin/perl

use strict;
use utf8;
use open qw(:std :utf8);


while (<>) {
    chomp;
    
    $_ =~ s/ -/-/gi;
    $_ =~ s/<sil>/{sil}/g;

    $_ =~ s/rendez vous/rendez-vous/g;
    $_ =~ s/euh ?//g;

    $_ =~ s/c' ?est[ -]?[aà][ -]?dire/c'est-à-dire/g;

    $_ =~ s/a[ -]?[ -]?t[ -]?[ -]il/a-t-il/g;
    $_ =~ s/a[ -]?[ -]?t[ -]?[ -]elle/a-t-elle/g;

    $_ =~ s/quan[td][ -][àa]/quant à/g;
    $_ =~ s/quan[td][ -]au/quant au/g;

    $_ =~ s/ euro(s)? / € /gi;
    $_ =~ s/^euro(s)? /€/gi;
    $_ =~ s/ euro(s)?$/ €/gi;

    $_ =~ s/ dollar(s)? / \$ /gi;
    $_ =~ s/^dollar(s)? /\$/gi;
    $_ =~ s/ dollar(s)?$/ \$/gi;

    # Remove duplicate words
    $_ =~ s/(\b\w+\b)(?:\s*\1)+/$1/g;


    # Unbreakable spaces
    $_ =~ s/(\d+) mill/$1 mill/gi;
    $_ =~ s/(\d+) tonne/$1 tonne/gi;
    $_ =~ s/(\d+) €/$1 €/g;

    $_ =~ s/(\d+) degré(s)?.?celsius/$1 °C/gi;
    $_ =~ s/(\d+) degré(s)?/$1 °/gi;

    $_ =~ s/(\d+) kilomètre(s)?/$1 km/gi;

    $_ =~ s/numéro(s)? (\d+)/n° $2/gi;


    $_ =~ s/oeuvre/œuvre/gi;
    $_ =~ s/coeur/cœur/gi;
    $_ =~ s/voeu/vœu/gi;
    $_ =~ s/oeuf/œuf/gi;
    $_ =~ s/noeud/nœud/gi;
    $_ =~ s/foetus/fœtus/gi;
    $_ =~ s/oeil/œil/gi;
    $_ =~ s/au delà/au-delà/gi;
    $_ =~ s/elpoint/L./gi;

    $_ =~ s/'/’/g;

    print "$_\n";
}
