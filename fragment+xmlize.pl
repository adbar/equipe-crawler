#!/usr/bin/perl


###	This script is part of the Équipe-Crawler v1.1 (http://code.google.com/p/equipe-crawler/).
###	It is brought to you by Adrien Barbaresi.
###	It is freely available under the GNU GPL v3 license (http://www.gnu.org/licenses/gpl.html).

# Function : expects a file named 'EQUIPE_flatfile' and converts it to a series of XML documents on a 'one file per text' basis.
# The files are stored in a subdirectory which must already exist (the default is 'texts').
# Use : without arguments.

# Benefits : compatibility with other software to complete a further analysis of the texts.
# For example the textometry software TXM : http://txm.sourceforge.net/

## The XML conversion was written with robustness in mind, but it does not provide a handy solution for all possible caveats, especially unicode (bad) character encoding issues. As the input may be a large corpus resulting from a web crawl, this script does not guarantee by design that the XML files will be valid.


use strict;
use warnings;

my ($text, $output);
my $counter = 0;
my $subdir = "texts"; ## change subdirectory here

my $input = "EQUIPE_flatfile";
open (INPUT, "<", $input) or die "Can't open $input: $!";

while (<INPUT>) {
	$text .= $_;
	if ($_ =~ m/^-----$/) {
		$text = xmlize($text);
		$text =~ s/Info: (.*?)\nDate: (.*?)\nTitre: (.*?)\nEn-tete: (.*?)\nPhoto: (.*?)\nurl: (.*?)\n\n(.+?)-----/<text info="$1" date="$2" titre="$3" entete="$4" photo = "$5" url="$6">\n<rohtext>\n$7<\/rohtext>\n<\/text>/s;
		$counter++;
		$output = $subdir . "/EQUIPE_text-" . $counter . ".xml";
		open (OUTPUT, ">", $output) or die "Can't open $output: $!";
		print OUTPUT "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
		print OUTPUT "<!--File generated by the equipe-crawler : http://code.google.com/p/equipe-crawler/-->\n";
		print OUTPUT "<!DOCTYPE text [
  <!ELEMENT text (rohtext)>
  <!ATTLIST text info CDATA #REQUIRED>
  <!ATTLIST text date CDATA #REQUIRED>
  <!ATTLIST text titre CDATA #REQUIRED>
  <!ATTLIST text entete CDATA #REQUIRED>
  <!ATTLIST text photo CDATA #REQUIRED>
  <!ATTLIST text url CDATA #REQUIRED>
  <!ELEMENT rohtext (#PCDATA)>
]>\n\n";
		print OUTPUT $text;
		$text = ();
		close(OUTPUT);
	}
}

close(INPUT);

sub xmlize {
	my $string = shift;
	$string =~ s/& /&amp;/g;
	$string =~ s/'/&apos;/g;
	$string =~ s/"/&quot;/g;
	return $string;
}
