### DESCRIPTION ###

Starting from the front page or from a given list of links, **the crawler retrieves newspaper articles and gathers new links to explore as it goes**, stripping the text of each article out of the HTML formatting and saving it into a raw text file.

Due to its specialization it is able to **build a reliable corpus consisting of texts and relevant metadata** (info, title, excerpt, photo caption, date und url). The list of links which comes with the software features about 40.000 articles, which enables to gather more than 10 millions of tokens.

As you can't republish anything but quotations of the texts, the purpose of this tool is to **enable others to make their own version of the corpus**, as crawling is not explicitly forbidden by the right-holders of _L'Équipe_.

The crawler does not support multi-threading as this may not be considered a fair use, it takes the links one by one and **it is not set up for speed**.

The **export in XML format** accounts for the compatibility with other software designed to complete a further analysis of the texts, for example the textometry software [TXM](http://txm.sourceforge.net/).


### FILES & USAGE ###

The initial release of the software can be downloaded as a [bundle (equipe-crawler-1.1.zip)](http://equipe-crawler.googlecode.com/files/equipe-crawler-1.1.zip) which includes a **list of links as well as scripts to convert raw data into the XML format** for further use with natural language processing tools.

For more information please refer to the [README file](http://code.google.com/p/equipe-crawler/source/browse/trunk/README).


### RESTRICTIONS ###

**The texts gathered using this software are for personal (or academic) use only**, you are not allowed to republish them :
http://www.lequipe.fr/Fonctions/pages_credits.html (in French)

The crawler was designed to get as little noise as possible. However, it is **highly dependant on the content management system and on the HTML markup** used by the newspaper _L'Équipe_. It worked by July 1st 2012, but it could break on future versions of the website and it may not be updated on a regular basis.

All the scripts should work correctly on **UNIX-like systems** if you set the right permissions. They may need a software like [Cygwin](http://www.cygwin.com/) to run on Windows, this case was not tested.


### CHANGELOG ###

1st August 2012 : v1.1 – Speed and memory use improvements for the crawler : replacement of the CRC function, better and reordered regular expressions, use of a hash to remove duplicates, a few bugs removed.