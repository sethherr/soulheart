#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib/')

require 'bundler'
require 'soulheart/server'

run Soulheart::Server