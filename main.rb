require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'nokogiri'
require 'open-uri'
require 'date'

require_relative 'linkfeeder'
require_relative 'linkclass'
require_relative 'dbcalls'
require_relative 'chart_parse'

genres = []

print 'Please name one genre to scrape. You\'ll have a chance to add more after pressing enter. '
genre_input = gets.chomp
genres << genre_input

while genre_input != 'done' && genre_input != 'Done' && genre_input != ''
  print 'If you have any more genres, write it and press enter. If not, write "done" or just press enter. '
  genre_input = gets.chomp
  if genre_input != 'done' && genre_input != 'Done' && genre_input != ''
    genres << genre_input
  else
  end
end

puts "You have chosen the following genres: #{genres.join(', ')}"

years = []

print 'Please name one year to scrape. You\'ll have a chance to add more after pressing enter. '
year_input = gets.chomp
years << year_input

while year_input != 'done' && year_input != 'Done' && year_input != ''
  print 'If you have any more years, write it and press enter. If not, write "done" or just press enter. '
  year_input = gets.chomp
  if year_input != 'done' && year_input != 'Done' && year_input != ''
    years << year_input
  else
  end
end

puts "You have chosen the following years: #{years.join(', ')}"

print 'Please give a name to the sqlite database you would like to use, without file extension '
db_input = gets.chomp

DBNAME = "#{db_input}.sqlite"
DB = SQLite3::Database.new(DBNAME)
DBcalls::create_table_master
DB.results_as_hash = true

feed = Feeder.new(genres, years)
puts feed.inspect

feed.feed

fed = Parse.new(feed)
fed.chart_parse_songs