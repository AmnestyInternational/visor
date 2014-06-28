#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'net/http'
require 'yaml'
require 'time'
require 'twitter'
require 'active_support/all'
require 'mysql'
require 'pry'

def loadyaml(yaml)
  begin
    return YAML::load(File.open(yaml))
  rescue Exception => e
    log_time("error loading #{yaml} - #{e.message}", 'error')
  end
end

def setvars
  @yml = loadyaml('config.yml')

  @db = Mysql.real_connect(@yml['database']['host'], @yml['database']['user'], @yml['database']['password'], @yml['database']['database'])

  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = @yml['twitter']['consumer_key']
    config.consumer_secret     = @yml['twitter']['consumer_secret']
    config.access_token        = @yml['twitter']['access_token']
    config.access_token_secret = @yml['twitter']['access_token_secret']
  end
end

def event
  {:name => @yml['event'].first['name'],
  :lat   => @yml['event'].first['lat'],
  :long  => @yml['event'].first['long'],
  :range => @yml['event'].first['range']}
end

setvars
