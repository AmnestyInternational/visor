#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'net/http'
require 'google_drive'
require 'yaml'
require 'time'
require 'twitter'
require 'active_support/all'
require 'pry'
require 'logger'

def log_time(input, type = 'info')
  puts Time.now.to_s + " " + type + ": " + input
  $LOG.error(input) if type == 'error'
  $LOG.info(input) if type == 'info'
  $LOG.warn(input) if type == 'warn'
  $LOG.debug(input) if type == 'debug'
  $LOG.fatal(input) if type == 'fatal'
end

$LOG = Logger.new('log.log')
# Set back to default formatter because active_support/all is messing things up
$LOG.formatter = Logger::Formatter.new  

def loadyaml(yaml)
  begin
    return YAML::load(File.open(yaml))
  rescue Exception => e
    log_time("error loading #{yaml} - #{e.message}", 'error')
  end
end

def fetch_tweets_from_event(twitter_client, event, since_id)
  log_time("Collecting tweets for " + event[:name] + " since " + since_id.to_s)
  parameters = { :geocode => "#{event[:lat]},#{event[:long]},#{event[:range]}km", :count => 100, :result_type => 'recent', :since_id => since_id }
  twitter_client.search( "", parameters ).to_h
end

def create_sheet_headers(sheet, headers)
  n = 1
  headers.each do |header|
    sheet[1,n] = header
    n +=1
  end
  sheet.save()
end

def stage_tweet(sheet, tweet, row)
  sheet[row, 1]  = "'" + tweet[:id].to_s
  sheet[row, 2]  = tweet[:text]
  sheet[row, 3]  = tweet[:created_at]
  sheet[row, 4]  = tweet[:retweet_count]
  sheet[row, 5]  = tweet[:favorite_count]
  sheet[row, 6]  = tweet[:source]
  sheet[row, 7]  = tweet[:geo][:coordinates][0]
  sheet[row, 8]  = tweet[:geo][:coordinates][1]
  sheet[row, 9]  = "'" + tweet[:user][:id].to_s
  sheet[row, 10] = tweet[:user][:name]
  sheet[row, 11] = tweet[:user][:screen_name]
  sheet[row, 12] = tweet[:user][:created_at]
  sheet[row, 13] = tweet[:user][:location]
  sheet[row, 14] = tweet[:user][:description]
  sheet[row, 15] = tweet[:user][:url]
  sheet[row, 16] = tweet[:user][:followers_count]
  sheet[row, 17] = tweet[:user][:friends_count]
  sheet[row, 18] = tweet[:user][:listed_count]
  sheet[row, 19] = tweet[:user][:favourites_count]
  sheet[row, 20] = tweet[:user][:statuses_count]
  sheet[row, 21] = tweet[:user][:utc_offset]
end

def stage_media(sheet, tweet, media, row)
  sheet[row,1] = "'" + media[:id].to_s
  sheet[row,2] = "'" + tweet[:id].to_s
  sheet[row,3] = media[:expanded_url]
  sheet[row,4] = media[:type]
end

def stage_hashtag(sheet, tweet, hashtag, row)
  sheet[row,1] = "'" + tweet[:id].to_s
  sheet[row,2] = hashtag
end

def stage_url(sheet, tweet, url, row)
  sheet[row,1] = "'" + tweet[:id].to_s
  sheet[row,2] = url
end

def stage_user_mention(sheet, tweet, user_mention, row)
  sheet[row,1] = "'" + tweet[:id].to_s
  sheet[row,2] = user_mention[:id]
  sheet[row,3] = user_mention[:screen_name]
end

log_time("Loading variables")

yml = loadyaml('config.yml')

log_time("Seting event parameters")

event = {
  :name  => yml['event'].first['name'],
  :lat   => yml['event'].first['lat'],
  :long  => yml['event'].first['long'],
  :range => yml['event'].first['range']}

log_time("Connecting to twitter API")

twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = yml['twitter']['consumer_key']
  config.consumer_secret     = yml['twitter']['consumer_secret']
  config.access_token        = yml['twitter']['access_token']
  config.access_token_secret = yml['twitter']['access_token_secret']
end

log_time("Connecting to Google Drive API")

session = GoogleDrive.login(yml['google']['user'], yml['google']['password'])

log_time("Loading sheets")

sheets = {}
sheets[:tweets]        = session.spreadsheet_by_key(yml['google']['doc']).worksheets[0]
sheets[:media]         = session.spreadsheet_by_key(yml['google']['doc']).worksheets[1]
sheets[:hashtags]      = session.spreadsheet_by_key(yml['google']['doc']).worksheets[2]
sheets[:urls]          = session.spreadsheet_by_key(yml['google']['doc']).worksheets[3]
sheets[:user_mentions] = session.spreadsheet_by_key(yml['google']['doc']).worksheets[4]
sheets[:meta]          = session.spreadsheet_by_key(yml['google']['doc']).worksheets[5]

log_time("Loading meta data")

meta = {}
meta[:since_id]               = sheets[:meta][1,2][/\d+/].to_i
meta[:tweets_last_row]        = sheets[:meta][4,2]
meta[:media_last_row]         = sheets[:meta][5,2]
meta[:hashtags_last_row]      = sheets[:meta][6,2]
meta[:urls_last_row]          = sheets[:meta][7,2]
meta[:user_mentions_last_row] = sheets[:meta][8,2]


log_time("Setting sheet headers")
create_sheet_headers(sheets[:tweets], ['tweet id','text','tweet created_at','retweeted count','favorite count','source','lat','long','user id','user name','screen name','user created_at','user location','user description','user url', 'followers count', 'friends count', 'listed count', 'favourites count', 'statuses count', 'utc offset'])
create_sheet_headers(sheets[:media], ['media id','tweet id','expanded url', 'media type'])
create_sheet_headers(sheets[:hashtags], ['tweet id', 'hashtag'])
create_sheet_headers(sheets[:urls],  ['tweet id', 'url'])
create_sheet_headers(sheets[:user_mentions], ['tweet id', 'user id', 'user screen name'])


loop do
  log_time("Reloading meta data")
  sheets[:meta].reload
  log_time("Collecting last rows meta data")
  tweet_row        = meta[:tweets_last_row].to_i
  media_row        = meta[:media_last_row].to_i
  hashtag_row      = meta[:hashtags_last_row].to_i
  url_row          = meta[:urls_last_row].to_i
  user_mention_row = meta[:user_mentions_last_row].to_i

  log_time("Fetching Twitter statuses")
  tweets = fetch_tweets_from_event(twitter_client, event, meta[:since_id])
  log_time("#{tweets[:statuses].length} fetched")

  log_time("Staging tweets")
  tweets[:statuses].each do |tweet|
    tweet_row += 1
    stage_tweet(sheets[:tweets], tweet, tweet_row)

    unless tweet[:entities][:media].nil?
      tweet[:entities][:media].each do |media|
        media_row += 1
        stage_media(sheets[:media], tweet, media, media_row)
      end
    end

    unless tweet[:entities][:hashtags].nil?
      tweet[:entities][:hashtags].each do |hashtag|
        hashtag_row += 1
        stage_hashtag(sheets[:hashtags], tweet, hashtag[:text], hashtag_row)
      end
    end

    unless tweet[:entities][:urls].nil?
      tweet[:entities][:urls].each do |url|
        url_row += 1
        stage_url(sheets[:urls], tweet, url[:expanded_url], url_row)
      end
    end

    unless tweet[:entities][:user_mentions].nil?
      tweet[:entities][:user_mentions].each do |user_mention|
        user_mention_row += 1
        stage_user_mention(sheets[:user_mentions], tweet, user_mention, user_mention_row)
      end
    end

  end
  log_time("Saving staged tweets to sheet")
  sheets[:tweets].save()
  log_time("Saving staged media to sheet")
  sheets[:media].save()
  log_time("Saving staged hashtags to sheet")
  sheets[:hashtags].save()
  log_time("Saving staged urls to sheet")
  sheets[:urls].save()
  log_time("Saving staged user_mentions to sheet")
  sheets[:user_mentions].save()


  log_time("Staging max since_id to " + tweets[:search_metadata][:max_id].to_s)
  sheets[:meta][1,2]  = "'" + tweets[:search_metadata][:max_id].to_s

  log_time("Staging last rows")
  sheets[:meta][4,2] = tweet_row
  sheets[:meta][5,2] = media_row
  sheets[:meta][6,2] = hashtag_row
  sheets[:meta][7,2] = url_row
  sheets[:meta][8,2] = user_mention_row

  log_time("Saving staged data to sheet")
  sheets[:meta].save()

  log_time("sleeping for 60 seconds")
  sleep 60
end
