#!/usr/bin/perl

while(<>) {
	chomp;
	if (m/^;;/) {
		next;
	}
	s/ euh//;

	($show, $c, $spk, $start, $len, $info, @wlst) = split(/ +/);
	if ($spk =~ m/excluded_region/) {
		next;
	}
	if ($spk =~ m/inter_segment_gap/) {
		next;
	}

    if (join('', @wlst) eq '') {
        next;
    }

	foreach $w (@wlst) {
		if ($w =~ m/[\[<]/ || $w eq 'euh') {
			next;
		}
		print "$w ";
	}
	print "\n";
}
