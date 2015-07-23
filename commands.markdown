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
          -s, --stop-words [FILE]          Path to file containing a list of stop words to overwrite defaults - "the", "at", "vs"
          -h, --help                       Show this message
          -A, --no-all                     on load: Do not add items into the "all" category (on load)
          -C, --no-combinatorial           Do not create combined categories, do not add items to combined categories (on load)
          -R, --remove-results             Remove results data - breaks the cache, fully clears all loaded data. (on clear)

      Commands:
        load   FILE  Loads data from a FILE - can be a local file or a url. Accepted formats are .json, .tsv and .csv
        reset        Removes all existing data (optionally pass a file to run load after reset)



### load

Combinatorial categories leads to rapid database growth. In many situations it isn't actually the behavior you want - e.g. if users are your categories (to provide each user with separate type ahead response), there is no reason they would ever need to be combined. Pass the no-combinatorial and the no-all flags to avoid exponentially growing the database with each new user - `soulheart -AC load FILENAME`.


### reset

For `reset` - Soulheart caches responses to searches for up to 10 minutes, which is convenient when reloading data because it prevents empty responses while you're loading. If you're really sure you want to clear everything, pass the `-R` flag. 

If you want to clear the database and load new data in, you can pass a filename in the command: `soulheart reset FILENAME`