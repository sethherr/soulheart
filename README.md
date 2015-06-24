# <img src="https://raw.githubusercontent.com/sethherr/soulheart/master/logo.png" alt="Soulheart" width="200"> Soulheart [![Build Status](https://travis-ci.org/sethherr/soulheart.svg)](https://travis-ci.org/sethherr/soulheart) [![Code Climate](https://codeclimate.com/github/sethherr/soulheart/badges/gpa.svg)](https://codeclimate.com/github/sethherr/soulheart) [![Test Coverage](https://codeclimate.com/github/sethherr/soulheart/badges/coverage.svg)](https://codeclimate.com/github/sethherr/soulheart/coverage)

To get started, check out examples and documentation at [sethherr.github.io/soulheart/](https://sethherr.github.io/soulheart/).

**Soulheart is a ready-to-use remote data source for autocomplete**. It supports:

- pagination
- categories
- sorting by priority (not just alphabetically)
- arbitrary return values/objects
- loading data via gists (or any url)
- mounting standalone or inside of a rails app

... and is [instantly deployable to heroku](https://heroku.com/deploy) (for free).


This project is in Beta. It's probably appropriate to use in production... but maybe wait? There are a few more changes coming, and some documentation improvements to be made.

=======

I'm testing with: `ruby 2.1` and `redis 3.0`. 

Run `bundle exec guard` to run the specs when they change as you work.

This repo includes a `config.ru` and a `Gemfile.lock` so it and any forks of it can be deployed to Heroku. They shouldn't be in the Gem. if you build it separately.

======

[There is issue for improving documentation](../../issues/1) because the documentation needs to be improved. Also, for serious, check out [sethherr.github.io/soulheart/](https://sethherr.github.io/soulheart/).

=====


This is a fork of [Soulmate](https://github.com/seatgeek/soulmate). It isn't backward compatible.