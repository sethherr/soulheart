# <img src="https://raw.githubusercontent.com/sethherr/soulheart/master/logo.png" alt="Soulheart" width="200"> Soulheart [![Build Status](https://travis-ci.org/sethherr/soulheart.svg)](https://travis-ci.org/sethherr/soulheart) [![Code Climate](https://codeclimate.com/github/sethherr/soulheart/badges/gpa.svg)](https://codeclimate.com/github/sethherr/soulheart) [![Test Coverage](https://codeclimate.com/github/sethherr/soulheart/badges/coverage.svg)](https://codeclimate.com/github/sethherr/soulheart/coverage)

Soulheart is a ready-to-use remote data source for autocomplete. The goal is to provide a solid, flexible tool that's downright simple to set up.

- [Demos](https://sethherr.github.io/soulheart/)
- [Usage documentation](https://sethherr.github.io/soulheart/commands/)
- [Example data sources](https://github.com/sethherr/soulheart/tree/master/example_data_sources)
- [Getting started](#getting-started)
- [Deployment](#deployment)
- [Testing](#testing)


## Features

- **Pagination**
  <br>For infinite scrolling of results - wow!
- **Categories**
  <br>Match results for specified categories, or not - your choice.
- **Prioritization**
  <br>Return results sorted by priority (not just alphabetically).
- **Arbitrary return objects**
  <br>Get whatever you want back. IDs, URLs, image links, even pre-formatted HTML :boom:
- **Load remote data**
  <br>Loading data via a [gist](https://github.com/sethherr/soulheart/blob/master/example_data_sources/manufacturers.tsv) - or any url.
- **Runs Standalone or inside a rails app**

## Getting started

See the [Soulheart demos page](https://sethherr.github.io/soulheart/) for a step-by-step explanation of creating an instance and setting up a select box that uses it as a remote data source.


## Deployment

#### With Heroku [![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

You can instantly deploy Soulheart to Heroku for free - just click the button - which deploys this repository using `rackup` to start the server. Because of this, there's a `config.ru` and a `Gemfile.lock`&mdash;to make it (and any forks) runnable on Heroku. These files aren't in the Gem.

To update your Heroku deploy of Soulheart, use the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-command) and redeploy the app: 
  
    heroku deploy -a NAME_OF_YOUR_APP_ON_HEROKU
    

#### In a Rails app

Soulheart is also a gem. Add it to your gemfile:

    gem 'soulheart'

And then put this in your routes.rb -

    require 'sidekiq/web'
    mount Soulheart::Server => "/soulhearts"

You can then access the server when your rails app is running. You can run the [Soulheart commands](https://sethherr.github.io/soulheart/commands/) from that directory.

## Testing

Tested with rspec, check out test information at [Code Climate](https://codeclimate.com/github/sethherr/soulheart).

Run `bundle exec guard` to watch for changes and rerun the tests when files are saved.


## Requirements

Soulheart is a Redis backed Sinatra server. I test with the latest MRI (2.2, 2.1, 2.0) and JRuby versions (1.7). Other versions/VMs are untested but might work fine.

It requires Redis 3.0

## Additional info

This started as a fork of [Soulmate](https://github.com/seatgeek/soulmate). It's MIT licensed.