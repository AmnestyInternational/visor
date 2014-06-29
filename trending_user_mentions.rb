#!/usr/bin/env ruby
require_relative 'google_docs_helper'

ws = @session.spreadsheet_by_key("1g6zo0phWS_hBpnn1PRZ1A-glW39d1QiaT7cQWpbfvnI").worksheets[0]

query = 'SELECT * FROM trending_user_mentions'

ws[1,1] = 'user'
ws[1,2] = 'mentions'

results = @db.query(query)

n = 2

results.each do |row|
  ws[n,1] = row['user']
  ws[n,2] = row['mentions']
  n += 1
end

ws.save
