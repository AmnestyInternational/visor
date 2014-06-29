#!/usr/bin/env ruby
require 'google_drive'
require 'yaml'
require 'mysql'
require 'mysql2'
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
  @db = Mysql2::Client.new(:host => @yml['database']['host'], :username => @yml['database']['user'], :password => @yml['database']['password'], :database => @yml['database']['database'])
  @session = GoogleDrive.login(@yml['google']['user'], @yml['google']['password'])
end

setvars
