#!/usr/bin/env ruby
require_relative 'google_docs_helper'

ws = @session.spreadsheet_by_key("1S0bwAdj8J29qFBvn0JFJ-maWYHNeqYnZrfj8dBtDbcw").worksheets[0]

query = 'SELECT * FROM trending_hashtags'

ws[1,1] = 'hashtag'
ws[1,2] = 'count'

results = @db.query(query)

n = 2

results.each do |row|
  ws[n,1] = row['hashtag']
  ws[n,2] = row['count']
  n += 1
end

ws.save