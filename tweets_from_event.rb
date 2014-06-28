#!/usr/bin/env ruby
require_relative 'twitter_helper'

def fetch_tweets_from_event(event, since_id = 0)
  parameters = { :geocode => "#{event[:lat]},#{event[:long]},#{event[:range]}km", :count => 100, :result_type => 'recent', :since_id => since_id }
  @client.search( "", parameters ).to_h
end

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

  sql = """
    REPLACE INTO twitter_users (user_id, name, screen_name, created_at, location, description, url, followers_count, friends_count, listed_count, favourites_count, statuses_count, utc_offset)
    VALUES (
      '#{tweet[:user][:id]}',
      '#{Mysql.escape_string(tweet[:user][:name].to_s)}',
      '#{Mysql.escape_string(tweet[:user][:screen_name].to_s)}',
      '#{DateTime.parse(tweet[:user][:created_at]).strftime("%Y-%m-%d %H:%M")}',
      '#{Mysql.escape_string(tweet[:user][:location].to_s)}',
      '#{Mysql.escape_string(tweet[:user][:description].to_s)}',
      '#{Mysql.escape_string(tweet[:user][:url].to_s)}',
      '#{tweet[:user][:followers_count]}',
      '#{tweet[:user][:friends_count]}',
      '#{tweet[:user][:listed_count]}',
      '#{tweet[:user][:favourites_count]}',
      '#{tweet[:user][:statuses_count]}',
      '#{tweet[:user][:utc_offset]}');\n"""

  puts sql

  @db.query(sql)
end

