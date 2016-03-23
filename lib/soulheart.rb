require 'multi_json'

require 'soulheart/version'
require 'soulheart/helpers'
require 'soulheart/base'
require 'soulheart/matcher'
require 'soulheart/loader'
require 'soulheart/config'
require 'soulheart/file_handler'

module Soulheart
  extend Config

  def self.load_file(filename, opts={})
    Soulheart::FileHandler.new(opts).load(filename)
  end

  def self.load_items(items, opts={})
    opts = {no_all: false, no_combinatorial: false}.merge(opts)
    Soulheart::Loader.new(opts).load(items)
  end
end
