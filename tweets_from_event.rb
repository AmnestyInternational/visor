#!/usr/bin/env ruby
require_relative 'twitter_helper'

def fetch_tweets_from_event(event, since_id = 0)
  parameters = { :geocode => "#{event[:lat]},#{event[:long]},#{event[:range]}", :count => 100, :result_type => 'recent', :since_id => since_id }
  Twitter.search( search_term, parameters ).results
end

binding.pry

fetch_tweets_from_event(event)