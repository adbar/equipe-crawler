#!/usr/bin/perl


###	This script is part of the Équipe-Crawler v1.1 (http://code.google.com/p/equipe-crawler/).
###	It is brought to you by Adrien Barbaresi.
###	It is freely available under the GNU GPL v3 license (http://www.gnu.org/licenses/gpl.html).

# Function : check the flatfile for duplicates, displays the number of different items.
# Use : without arguments.


use strict;
use List::MoreUtils qw(uniq);
use String::CRC32;


my $input = "flatfile";
my $titles = 0;
my (@titles, @excerpts, @urls, @buffer, @crc);

open (INPUT, '<', $input) or die;

while (<INPUT>) {
	if ($_ =~ m/^Titre: /) {
		push (@titles, $_);
	}
	elsif ($_ =~ m/^Excerpt/) {
		push (@excerpts, $_);
	}
	elsif ($_ =~ m/^url: /) {
		push (@urls, $_);
	}
	if ($_ eq "-----\n") {
		push (@crc, crc32(join("",@buffer)));
		@buffer= ();
	}
	else {
		if ( ($_ !~ m/^Info: /) && ($_ !~ m/^Date: /) && ($_ !~ m/^Photo: /) ) {
		push (@buffer, $_);
		}
	}
}

print "titles:\t\t" . scalar (@titles) . "\t" . scalar (uniq @titles) . "\n";
print "excerpts:\t" . scalar (@excerpts) . "\t" . scalar (uniq @excerpts) . "\n";
print "urls:\t\t" . scalar (@urls) . "\t" . scalar (uniq @urls) . "\n";
print "text crc:\t" .scalar (@crc) . "\t" . scalar (uniq @crc) . "\n";
