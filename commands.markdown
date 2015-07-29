---
layout: default
title: Commands
permalink: /commands/
---

<div class="page-header"><h1>
Commands <small>usage documentation</small>
</h1>
</div>


    Usage: soulheart [options] COMMAND

    Options:
        -r, --redis [HOST:PORT]          Redis connection string
        -h, --help                       Show this message

      load options:
        -A, --no-all                     Do not add items into the "all" category
        -C, --no-combinatorial           Do not create combined categories, do not add items to combined categories

      normalize options:
        -s, --with-symbols               Do not remove symbols when normalizing terms
        -x, --regex                      Use the first line from the FILE as the regular expression for normalizing terms

      clear options:
        -R, --remove-results             Remove results data - breaks the cache, fully clears all loaded data

    Commands:
      load        FILE   Loads data from a FILE - can be a local file or a url. Accepted formats are .json, .tsv and .csv
      stop-words  FILE   Load file containing a list of stop words to overwrite defaults - 'the', 'at' and 'vs'
      normalize          Set the way that terms are normalized. Requires a file when using the --regex option
      clear              Removes existing items and categories from the database

    Additional info: https://sethherr.github.io/soulheart/commands/



### load

Combinatorial categories leads to rapid database growth.

In many situations it isn't actually the behavior you want - e.g. if users are your categories (to provide each user with unique type ahead response), there's no reason they would ever need to be combined.

Pass the `no-combinatorial` and the `no-all` flags when loading data to avoid exponentially growing the database with each new user - `soulheart -AC load FILENAME`.


### clear

`clear` removes the items in the database. It does not reset the stop words or change the normalize function.

Soulheart caches responses to searches for up to 10 minutes, which is convenient when reloading data because it prevents empty responses while you're loading. If you're really sure you want to clear everything, pass the `-R` flag.

### stop-words

`stop-words` sets the stop words. Pass it a file (or a url) with new-line delineated list of words to stop on.

The default stop words are: 
    
    at
    the
    vs

Stop words are saved in redis, so they work between loads and when restarting the server. 

<div class="alert alert-warning">
<h4>After running this command you must:</h4>
<ul><li><strong>restart the server</strong></li>
<li><strong>reload</strong> your data!</li></ul>
</div>

To restart a server on Heroku, run `heroku restart -a app_name`

Because this applies to both data and results, it will break things if you don't re-load the data. So run `soulheart load` with the data you had in there previously.

### normalize

`normalize` sets the way that data is processed and matched. There are three possible options for this:

1. No passed options. Sets it to default - strips out symbols and extra white space.
2. `--with-symbols` which doesn't remove symbols.
3. `--regex` which loads a file (or url) and uses that as the expression to normalize. (e.g. `soulheart --regex normalize FILENAME`)


<div class="alert alert-warning">
<h4>After running this command you must:</h4>
<ul><li><strong>restart the server</strong></li>
<li><strong>reload</strong> your data!</li></ul>
</div>

Because this applies to both data and results, it will break things if you don't re-load the data. So run `soulheart load` with the data you had in there previously.