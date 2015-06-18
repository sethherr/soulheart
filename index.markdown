---
layout: default
---


#<img src="https://raw.githubusercontent.com/sethherr/soulheart/master/logo.png" alt="Soulheart" width="200"> Hello. This is soulheart.

Haven't you wished there was a super easy way to set up a remote data source for type ahead?

-----

So, for example, let's say you want to have bike manufacturers. This is using select2.

To get this on heroku: 

[![deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)  then run:

    heroku run -a <<name of the heroku app>> soulheart load https://raw.githubusercontent.com/sethherr/soulheart/gh-pages/example_sources/manufacturers.tsv

(in this case, the heroku app is `example_soulheart_manufacturers`)

### Adding data

You can add data from JSON, CSV and TSV files. 

Items can be very simple - all that is required is a `text` value.

Soulheart uses [line delineated JSON streams](https://en.wikipedia.org/wiki/JSON_Streaming#Line_delimited_JSON), so it doesn't have to load the whole file into memory. Which just means - put each object onto a seperate line.

For the simplest case, with just text values in JSON:

    { "text": "Jamis" }
    { "text": "Specialized" }
    { "text": "Trek" }

It accepts local files:

    soulheart load my_json_file.json

or remote files:
  
    soulheart load https://raw.githubusercontent.com/sethherr/soulheart/gh-pages/example_sources/manufacturers.tsv


In addition to term, there are a few optional values - 

| Key          | Default     | What it does |
| ------------ | ----------- | ------------ |
| `priority`   | `100`       | Higher numbers come first |
| `category`   | `'default'` | Sets the category |
| `data`       | `{}`        | Returned object from search - the text and category will be added to this if you don't specify them. |

Here is an example of what a possible hash you could pass is

    { "text": "Jamis", "category": "Bike Manufacturer" }
    { "text": "Specialized" }
    { "text": "Trek" }

*If you set `text` in `data`, it will respond with that rather than the term it searches by. I haven't figured out a use case for this yet, but I'm sure one exists.*

======

I'm testing with: `ruby >= 2.1` and `redis >= 3`. 

Run `bundle exec guard` to run the specs while you work, it will just test the files you change.

This repo includes a `config.ru` and a `Gemfile.lock` so it (and any forks of it) can be deployed to heroku. They shouldn't be in the Gem itself.


======