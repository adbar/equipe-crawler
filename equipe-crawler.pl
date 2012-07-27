#!/usr/bin/perl


###			EQUIPE-CRAWLER v1.0			###
###		http://code.google.com/p/equipe-crawler/ 	###

###	This script is brought to you by Adrien Barbaresi.
###	It is freely available under the GNU GPL v3 license (http://www.gnu.org/licenses/gpl.html).
###	Five files are generated by the program (some are needed to go on crawling).

###	The crawler does not support multi-threading, as this may not be considered a fair use.
###	The gathered texts are for personal (or academic) use only, you cannot republish them :
###	http://www.lequipe.fr/Fonctions/pages_credits.html (in French)


## Use : change the number of pages crawled to fit your needs (the program supports successive executions).
## Execute the file without arguments.


use strict;
use warnings;
#use locale;
use utf8;
use Encode;
use LWP::Simple;
# The modules below probably need to be installed, e.g. using the CPAN console or directly with the Debian/Ubuntu packages libtext-trim-perl and libstring-crc32-perl
use Text::Trim;
use String::CRC32;


#Init
my $recup = "http://www.lequipe.fr/";

# Change number of pages crawled at a time here
my $number = 1000;

my $runs = 1;
my ($url, $urlcorr, $block, $seite, $n, @text, $titel, $excerpt, $info, $autor, $datum, @reihe, $link, @links, @temp, @done, $line, %seen);
my (@buffer, $q);
my ($crc, @done_crc, $links_crc);

my $output = ">>EQUIPE_flatfile";
open (OUTPUT, $output) or die;
my $record = '>>EQUIPE_log';
open (TRACE, $record) or die;
my $done = '>>EQUIPE_list_done';
open (DONE, $done);

##Loading...
print "Initialisation...\n";

my $done_crc = 'EQUIPE_list_done_crc';
my %done_crc;
if (-e $done_crc) {
open (DONE_CRC, $done_crc) or die;
$line = 0;
	while (<DONE_CRC>) {
	chomp;
	$done_crc{$_}++;
	$done_crc[$line] = $_;
	$line++;
	}
close (DONE_CRC) or die;
}

my $links = 'EQUIPE_list_todo';
my @liste;
if (-e $links) {
open (LINKS, $links) or die;
my $i = 0;
	while (<LINKS>) {
	chomp;
	$crc = crc32($_);
	unless (exists $done_crc{$crc}) {
	push (@liste, $_);
	}
	}
%seen = ();
@liste = grep { ! $seen{ $_ }++ } @liste; # remove duplicates (fast)
close (LINKS) or die;
}


# Begin of the main loop

print "run -- list -- buffer\n";
while ($runs <= $number) {

if (@liste) {
$url = splice (@liste, 0, 1);
}
else {
$url = $recup;
}

push (@done_crc, crc32($url));
$done_crc{crc32($url)}++;
print DONE $url, "\n";

# Change output frequency here :
if ($runs%10 == 0) {
print $runs, "\t"; print scalar (@liste), "\t"; print scalar (@buffer), "\n";
}

print TRACE "$runs\t"; print TRACE scalar (@liste), "\n";
print TRACE "$url\n";

my (@text, $titel, $excerpt, $info, $photo, $date);

#Fetch the page
if ($url !~ m/^http:\/\/www\.lequipe\.fr/o) {
	$urlcorr = "http://www.lequipe.fr/" . $url;
	$seite = get $urlcorr;
}
else {
	$seite = get $url;
}
# re-encoding seems to be necessary
$seite = encode("iso-8859-1", $seite);


# Links
@links = ();
@temp = split ("<a", $seite);
foreach $n (@temp) {

#if ( ($n =~ m/\/Actualites/) || ($n =~ m/\/breves20/) ) {
if ($n =~ m/\/Actualites/o) {
	next if ($n =~ m/redir\.php/o);
	$n =~ m/href="(.+?)"/o;
	$n = $1;
	$n =~ s/^http:\/\/log.+?xiti.com\/go.click?.+?&url=//o;
	$n =~ s/^http:\/\/www\.lequipe\.fr\///o;
	$n =~ s/^\///o;
	push (@links, $n);
}
}

%seen = ();
@links = grep { ! $seen{ $_ }++ } @links; # remove duplicates (fast)

# Storing and buffering links
# The use of a buffer saves memory and processing time (especially by frequently occurring links)
$q=0;
foreach $n (@links) {
	if ($q >= 5) {
	push (@buffer, $n);
	}
	else {
		$crc = crc32($n);
		unless (exists $done_crc{$crc}) {
		push (@liste, $n);
		}
	}
	$q++;
}


# Buffer control
if (scalar @buffer >= 1000) {
	%seen = ();
	@buffer = grep { ! $seen{ $_ }++ } @buffer; # remove duplicates (fast)
	foreach $n (@buffer) {
		$crc = crc32($n);
		unless (exists $done_crc{$crc}) {
		push (@liste, $n);
		}
	}
	@buffer = ();
}

%seen = ();
@liste = grep { ! $seen{ $_ }++ } @liste; # remove duplicates (fast)


# Extraction of metadata
# All this part is based on regular expressions, which is not recommended when crawling in the wild.
{ no warnings 'uninitialized';

# Old design of the HTML code
if ($seite =~ m/<div id="corps">/o) {

	@temp = split ("<div id=\"corps\">", $seite);
	$seite = $temp[1];
	@temp = split ("<div id=\"bloc_bas_breve\">", $seite);
	$seite = $temp[0];

	$seite =~ m/(<h2>)(.+?)(<\/h2>)/o;
	$info = $2;
	
	$seite =~ m/(<h1>)(.+?)(<\/h1>)/o;
	$titel = $2;

	if ($seite =~ m/<strong>/o) {
		$seite =~ m/(<strong>)(.+?)(<\/strong>)/o;
		$excerpt = $2;
		$seite =~ s/<strong>.+?<\/strong>//o;
	}

	if ($seite =~ m/<strong>/o) {
	$seite =~ m/(<div class="leg">?)(.+?)(<\/div>)/o;
	$photo = $2;
	$seite =~ s/<div class="leg">.+?<\/div>//o;
	}

	$seite =~ s/<h2>.+?<\/h2>//og;
	$seite =~ s/<h1>.+?<\/h1>//og;

	# Possible improvement : author detection
	#<div id="auteur">
        #        <span>Le 04/07/2010 à 14:58</span>
        #</div>
}

# New design of the HTML code
else {
	@temp = split ("<div id=\"container\">", $seite);
	$seite = $temp[1];
	@temp = split ("<div id=\"bloc_bas_breve\">", $seite);
	$seite = $temp[0];

	if ($seite =~ m/<h1>(.+?)<\/h1>/o) {
		$titel = $1;
			if ($titel =~ m/<span>(.+?)<\/span>/o) {
				$info = $1;
				$info =~ s/ : $//o;
				$titel =~ s/<span>.+?<\/span>//o;
			}
	}
	
	if ($seite =~ m/<div class="chapeau">(.+?)<\/div>/o) {
		$excerpt = $1;
	}

	if ($seite =~ m/<div class="date">(.+?)<\/div>/o) {
		$date = $1;
		$date =~ m/([0-9]{2}\/[0-9]{2}\/[0-9]{4})/o;
		$date = $1;
	}

	if ($seite =~ m/<div class="caption">(.+?)<\/div>/os) {
		$photo = $1;
		$photo =~ s/<.+?>//og;
		$photo =~ s/\n//og;
		trim ($photo);
	}
}

if ($info) {$info = "Info: " . $info;}
else {$info = "Info: ";}
push (@text, $info);
if ($date) {$date = "Date: " . $date;}
else {$date = "Date: ";}
push (@text, $date);
if ($titel) {$titel = "Titre: " . $titel;}
else {$titel = "Titre: ";}
push (@text, $titel);
if ($excerpt) {$excerpt = "En-tete: " . $excerpt;}
else {$excerpt = "En-tete: ";}
push (@text, $excerpt);
if ($photo) {$photo = "Photo: " . $photo;}
else {$photo = "Photo: ";}
push (@text, $photo);

push (@text, "url: $url\n");


# Extraction of the text itself
# Using regular expressions, there might be a more efficient way to do this.

@temp = split ("<div class=\"col-460\">", $seite);
$seite = $temp[1];

$seite =~ s/<script type="text\/javascript">.+?<\/script>//ogs;
$seite =~ s/<p>/\n/og;
$seite =~ s/<br>/\n/og;
$seite =~ s/<\/div>/\n/og;
$seite =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//ogs;
$seite =~ s/Tweet|Twitter//og;
$seite =~ s/sas_fo.+$//og;
$seite =~ s/SmartAd.+$//og;
$seite =~ s/&quot/\"/og;
$seite =~ s/&nbsp;/ /og;

$seite =~ s/^\s+//og;
$seite =~ s/\s+/ /og;
$seite =~ s/\n+/\n/og;

$seite =~ s/Envoyer à un ami//og;

push (@text, $seite);

# Does not print out an empty text
if (length ($seite) > 10) {
	foreach $n (@text) {
		# Due to an irregular HTML encoding...
		$_ =~ s/&nbsp;/ /og;
		$_ =~ s/&mdash;/-/og;
		$_ =~ s/&eacute;/é/og;
		$_ =~ s/&egrave;/è/og;
		$_ =~ s/&agrave;/à/og;
		$_ =~ s/&euro;/€/og;
		$_ =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//og;
		$_ =~ s/&rsquo;/&apos;/og;
		$_ =~ s/&deg;/°/og;
		$_ =~ s/&copy;/©/og;
		print OUTPUT "$n\n";
	}
	print OUTPUT "-----\n";
}
} # end of the no warnings 'uninitialized' pragma

if ( (scalar @liste == 0) && (@buffer) ) {
	%seen = ();
	@buffer = grep { ! $seen{ $_ }++ } @buffer; # remove duplicates (fast)
	foreach $n (@buffer) {
		$crc = crc32($n);
		unless (exists $done_crc{$crc}) {
		push (@liste, $n);
		}
	}
	@buffer = ();
	%seen = ();
	@liste = grep { ! $seen{ $_ }++ } @liste; # remove duplicates (fast)
}

if ( (scalar (@liste) == 0) && (scalar (@buffer) == 0) ) {
last;
}

$runs++;
}

# End of processing, saving lists 
close (OUTPUT);
close (DONE);

$done_crc = '>EQUIPE_list_done_crc';
sort (@done_crc);
open (DONE_CRC, $done_crc);
foreach $n (@done_crc) {
print DONE_CRC "$n\n";
}
close (DONE_CRC);

$links = '>EQUIPE_list_todo';
open (LINKS, $links) or die;
if (@buffer) {
	push (@liste, @buffer);
	print "Buffer stored\n";
}
%seen = ();
@liste = grep { ! $seen{ $_ }++ } @liste; # remove duplicates (fast)
foreach $n (@liste) {
print LINKS "$n\n";
}
close (LINKS);

print TRACE "***************\n";
close (TRACE);
