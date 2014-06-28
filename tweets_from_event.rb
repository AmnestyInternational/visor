#!/usr/bin/env ruby
require_relative 'twitter_helper'

def fetch_tweets_from_event(event, since_id = 0)
  parameters = { :geocode => "#{event[:lat]},#{event[:long]},#{event[:range]}km", :count => 100, :result_type => 'recent', :since_id => since_id }
  @client.search( "", parameters ).to_h
end

binding.pry

fetch_tweets_from_event(event)