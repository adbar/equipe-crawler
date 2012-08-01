#!/bin/bash

###	This shell script is part of the Équipe-Crawler v1.1 (http://code.google.com/p/equipe-crawler/).
###	It is brought to you by Adrien Barbaresi.
###	It is freely available under the GNU GPL v3 license (http://www.gnu.org/licenses/gpl.html).


# To use after a succesful crawl.
# Function : create a compressed backup of the crawl files and delete them.
# Should work on all UNIX-like systems.

tar -cvjf EQUIPE_crawl_`date +%F`.tar.bz2 EQUIPE_*
rm EQUIPE_*
