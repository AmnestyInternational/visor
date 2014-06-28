#!/usr/bin/env ruby
require_relative 'twitter_helper'

def fetch_tweets_from_event(event, since_id = 0)
  parameters = { :geocode => "#{event[:lat]},#{event[:long]},#{event[:range]}km", :count => 100, :result_type => 'recent', :since_id => since_id }
  @client.search( "", parameters ).to_h
end

sql = ""

fetch_tweets_from_event(event)[:statuses].each do |tweet|
  sql = """
    REPLACE INTO tweets (tweet_id, user_id, text, created_at, retweet_count, favorite_count)
    VALUES (
      '#{tweet[:id]}',
      '#{tweet[:user][:id]}',
      '#{Mysql.escape_string(tweet[:text])}',
      '#{DateTime.parse(tweet[:created_at]).strftime("%Y-%m-%d %H:%M")}',
      '#{tweet[:retweet_count]}',
      '#{tweet[:favorite_count]}');\n"""

  puts sql

  @db.query(sql)
end

