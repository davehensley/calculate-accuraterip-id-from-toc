#!/usr/bin/perl

use integer;
use strict;
use warnings;
use Data::Dumper;

sub parse_toc {
	my $toc = shift;
	my @parsed_toc = ();

	foreach my $line (split /\n/, $toc) {
		my @fields = ();

		foreach my $field (split /\|/, $line) {
			$field =~ s/^\s+|\s+$//g;
			push @fields, $field;
		}

		if ($fields[0] && ($fields[0] =~ /^\d{1,2}$/)) {
			push @parsed_toc, [@fields];
		}
	}

	return @parsed_toc;
}

sub sum_digits {
	my $n = shift;
	my $r = 0;

	while ($n > 0) {
		$r = $r + ($n % 10);
		$n = int($n / 10);
	}

	return $r;
}

if (!@ARGV) {
    die "You must specify a .toc file!\n";
}

open(INFILE, $ARGV[0]) || die "Could not open the .toc file!\n";
my $toc = '';

while (<INFILE>) {
	$toc .= $_ . "\n";
}

close INFILE;
my @parsed_toc = parse_toc($toc);
my ($disc_id_1, $disc_id_2, $cddb_disc_id) = (0, 0, 0);
my $enhanced_cd = 0;

for (my $track_number = 0; $track_number <= scalar @parsed_toc; $track_number++) {
	my $track_offset;

	if ($track_number < (scalar @parsed_toc)) {
		$track_offset = $parsed_toc[$track_number][3];
		$cddb_disc_id = $cddb_disc_id + sum_digits(int($track_offset/75) + 2);

		if ($track_number && ($parsed_toc[$track_number][3] > 1 + $parsed_toc[$track_number - 1][4])) {
			# This is a data track on an enhanced CD, so we have to do some goofy stuff here.
			$track_offset = 1 + $parsed_toc[$track_number][4];
			$enhanced_cd = 1;
		}
	} else {
		$track_offset = $parsed_toc[-1][4] + 1;
	}

	$disc_id_1 += $track_offset;
	$disc_id_2 += ($track_offset ? $track_offset : 1) * ($track_number + 1);

	# Stop calculating the first 2/3 of the AccurateRip ID once we determine that this is an enhanced CD.
	if ($enhanced_cd) {
		last;
	}
}

$cddb_disc_id = (($cddb_disc_id % 255) << 24) + ((int(($parsed_toc[-1][4] + 1)/75) - int($parsed_toc[0][3]/75)) << 8) + (scalar @parsed_toc);
$disc_id_1 &= 0xFFFFFFFF;
$disc_id_2 &= 0xFFFFFFFF;
$cddb_disc_id &= 0xFFFFFFFF;

printf("%.8x-%.8x-%.8x\n", $disc_id_1, $disc_id_2, $cddb_disc_id);
