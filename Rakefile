#!/usr/bin/env rake

require "bundler/gem_helper"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

REDIS_DIR = File.expand_path(File.join("..", "test"), __FILE__)
REDIS_CNF = File.join(REDIS_DIR, "test.conf")
REDIS_PID = File.join(REDIS_DIR, "db", "redis.pid")
REDIS_LOCATION = ENV['REDIS_LOCATION']

desc "Run rcov and manage server start/stop"
task :rcoverage => [:start, :rcov, :stop]

desc "Start the Redis server"
task :start do
  redis_running = \
    begin
      File.exists?(REDIS_PID) && Process.kill(0, File.read(REDIS_PID).to_i)
    rescue Errno::ESRCH
      FileUtils.rm REDIS_PID
      false
    end

  if REDIS_LOCATION
    system "#{REDIS_LOCATION}/redis-server #{REDIS_CNF}" unless redis_running
  else
    system "redis-server #{REDIS_CNF}" unless redis_running
  end
end

desc "Stop the Redis server"
task :stop do
  if File.exists?(REDIS_PID)
    Process.kill "INT", File.read(REDIS_PID).to_i
    FileUtils.rm REDIS_PID
  end
end


require "rspec/core/rake_task"

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w(--color)
  t.verbose = false
end

task :default => :spec