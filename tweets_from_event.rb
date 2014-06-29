#!/usr/bin/env ruby
require_relative 'twitter_helper'

def fetch_tweets_from_event(event, since_id = 0)
  parameters = { :geocode => "#{event[:lat]},#{event[:long]},#{event[:range]}km", :count => 100, :result_type => 'recent', :since_id => since_id }
  @client.search( "", parameters ).to_h
end

fetch_tweets_from_event(event)[:statuses].each do |tweet|

  tweet_sql = """
    REPLACE INTO tweets (tweet_id, user_id, text, created_at, retweet_count, favorite_count, source, coordinates)
    VALUES (
      #{tweet[:id]},
      #{tweet[:user][:id]},
      #{twitter_strings_to_db(tweet[:text])},
      #{twitter_dates_to_db(tweet[:created_at])},
      #{tweet[:retweet_count]},
      #{tweet[:favorite_count]},
      #{twitter_strings_to_db(tweet[:source])},
      #{twitter_lat_long_to_db(tweet[:geo][:coordinates][0], tweet[:geo][:coordinates][1])});\n"""

  puts tweet_sql
  @db.query(tweet_sql)

  twitter_user_sql = """
    REPLACE INTO twitter_users (user_id, name, screen_name, created_at, location, description, url, followers_count, friends_count, listed_count, favourites_count, statuses_count, utc_offset)
    VALUES (
      #{tweet[:user][:id]},
      #{twitter_strings_to_db(tweet[:user][:name])},
      #{twitter_strings_to_db(tweet[:user][:screen_name])},
      #{twitter_dates_to_db(tweet[:user][:created_at])},
      #{twitter_strings_to_db(tweet[:user][:location])},
      #{twitter_strings_to_db(tweet[:user][:description])},
      #{twitter_strings_to_db(tweet[:user][:url])},
      #{tweet[:user][:followers_count]},
      #{tweet[:user][:friends_count]},
      #{tweet[:user][:listed_count]},
      #{tweet[:user][:favourites_count]},
      #{tweet[:user][:statuses_count]},
      #{twitter_int_to_db(tweet[:user][:utc_offset])});\n"""

  puts twitter_user_sql
  @db.query(twitter_user_sql)

  tweet_area_sql = """
    REPLACE INTO tweet_area (tweet_id, area)
    VALUES (
      #{tweet[:id]},
      #{twitter_strings_to_db(event[:name])});\n"""

  puts tweet_area_sql
  @db.query(tweet_area_sql)

  unless tweet[:entities][:media].nil?
    tweet[:entities][:media].each do |media|

      tweet_media_sql = """
        REPLACE INTO tweet_media (media_id, tweet_id, url, type)
        VALUES (
          #{media[:id]},
          #{tweet[:id]},
          #{twitter_strings_to_db(media[:expanded_url])},
          #{twitter_strings_to_db(media[:type])});\n"""

      puts tweet_media_sql
      @db.query(tweet_media_sql)

    end
  end

  unless tweet[:entities][:hashtags].empty?
    tweet[:entities][:hashtags].each do |hashtag|
      tweet_hashtag_sql = """
        REPLACE INTO tweet_hashtags (tweet_id, hashtag)
        VALUES (
          #{tweet[:id]},
          #{twitter_strings_to_db(hashtag[:text])});\n"""

      puts tweet_hashtag_sql
      @db.query(tweet_hashtag_sql)
    end
  end

  unless tweet[:entities][:symbols].empty?
    tweet[:entities][:symbols].each do |symbol|
      tweet_symbols_sql = """
        REPLACE INTO tweet_symbols (tweet_id, symbol)
        VALUES (
          #{tweet[:id]},
          #{twitter_strings_to_db(symbol[:text])});\n"""

      puts tweet_symbols_sql
      @db.query(tweet_symbols_sql)
    end
  end

  unless tweet[:entities][:urls].empty?
    tweet[:entities][:urls].each do |url|
      tweet_url_sql = """
        REPLACE INTO tweet_urls (tweet_id, url)
        VALUES (
          #{tweet[:id]},
          #{twitter_strings_to_db(url[:expanded_url])});\n"""

      puts tweet_url_sql
      @db.query(tweet_url_sql)
    end
  end

  unless tweet[:entities][:user_mentions].empty?
    tweet[:entities][:user_mentions].each do |user_mention|
      tweet_user_mention_sql = """
        REPLACE INTO tweet_user_mentions (tweet_id, user_id, screen_name)
        VALUES (
          #{tweet[:id]},
          #{user_mention[:id]},
          #{twitter_strings_to_db(user_mention[:screen_name])});\n"""

      puts tweet_user_mention_sql
      @db.query(tweet_user_mention_sql)
    end
  end

end

