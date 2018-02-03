require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'wannabe_bool'
require 'discogs-wrapper'

require_relative 'lib/linkfeeder'
require_relative 'lib/linkclass'
require_relative 'lib/dbcalls'
require_relative 'lib/chart_parse'
require_relative 'lib/discogsapi'
require_relative 'lib/spotifycleaning'
require_relative 'lib/echonestapi'
require_relative 'lib/lyricsearch'
require_relative 'lib/statistics'
require_relative 'lib/writetofile2'

instructs = File.open("instructs.txt", 'r')
instructs = instructs.readlines

scrape_songs = false
scrape_albums = false
song_genres = []
album_genres = []
years = []
db_input = nil
discogs = false
discogs_token = nil
spotify = false
echonest = false
lyrics = false
albums = false
overwrite = false
write = false
write_path = false
statistics = false
origdirectory = Dir.getwd

begin

instructs.each_with_index do |line, num|
  if line.match(/^## statistics/)
    puts "statistics = #{instructs[num+1]}"
    statistics = instructs[num+1].strip.to_b
  end
  if line.match(/^## overwrite/)
    puts "overwrite = #{instructs[num+1]}"
    overwrite = instructs[num+1].strip.to_b
  end
  if line.match(/^## albums/)
    puts "albums = #{instructs[num+1]}"
    albums = instructs[num+1].strip.to_b
  end
  if line.match(/^## scrape-albums/)
    puts "scrape-albums = #{instructs[num+1]}"
    scrape_albums = instructs[num+1].strip.to_b
  end
  if line.match(/^## path/)
    puts "write_path = #{instructs[num+1]}"
    write_path = instructs[num+1].strip
  end
  if line.match(/^## write/)
    puts "write = #{instructs[num+1]}"
    write = instructs[num+1].strip.to_b
  end
  if line.match(/^## lyric-search/)
    puts "lyrics = #{instructs[num+1]}"
    lyrics = instructs[num+1].strip.to_b
  end
  if line.match(/^## spotify/)
    puts "spotify = #{instructs[num+1]}"
    spotify = instructs[num+1].strip.to_b
  end
  if line.match(/^## echonest/)
    puts "echonest = #{instructs[num+1]}"
    echonest = instructs[num+1].strip.to_b
  end
  if line.match(/^## discogs/)
    puts "discogs = #{instructs[num+1]}"
    discogs = instructs[num+1].strip.to_b
  end
  if line.match(/^## token\-discogs/)
    puts "discogs-token = #{instructs[num+1]}"
    discogs_token = instructs[num+1].strip
  end
  if line.match(/^## scrape-songs/)
    puts "scrape-songs = #{instructs[num+1]}"
    scrape_songs = instructs[num+1].strip.to_b
  end
  if line.match(/^## song-genres/)
    puts "song-genres = #{instructs[num+1]}"
    genre_in = instructs[num+1]
    song_genres = genre_in.split(", ").collect{ |x| x.strip}
  end
  if line.match(/^## album-genres/)
    puts "album-genres = #{instructs[num+1]}"
    genre_in = instructs[num+1]
    album_genres = genre_in.split(", ").collect{ |x| x.strip}
  end
  if line.match(/^## years/)
    puts "years = #{instructs[num+1]}"
    year_in = instructs[num+1]
    years = year_in.split(", ").collect{ |x| x.strip}
  end
  if line.match(/^## dbname/)
    puts "dbname = #{instructs[num+1]}"
    db_input = instructs[num+1].strip
  end
end

# This creates the database. It will overwrite in case of a naming conflict if 'overwrite' is set to 'true'.
DBNAME = "#{db_input}"
if overwrite == true
  DB = SQLite3::Database.new(DBNAME)
  DBcalls::create_table_master
  DB.results_as_hash = true
else
  DB = SQLite3::Database.open(DBNAME)
  DBcalls::create_table_master
  DB.results_as_hash = true
end

if scrape_songs == true
  # This creates an object of objects of link type (think about that for a minute)
  feed = Feeder.new(song_genres, years)
  feed.feed

  # Now I'm sending all of those pre-built links to the parsing method that goes to the site and scrapes the data
  fed = Parse.new(feed)
  fed.chart_parse_songs
end

if albums == true

  if scrape_albums == true
    # This creates an object of objects of link type (think about that for a minute)
    feed2 = Feeder.new(album_genres, years)
    feed2.feed_albums

    DBcalls::create_album_master
    fed2 = Parse.new(feed2)
    fed2.chart_parse_albums
  end

  if discogs == true
    puts 'Getting tracklists for albums from Discogs...'
    DiscogsAPI::get_tracklists(db_input, discogs_token)
  end

  if spotify == true
    Spotifyclean::album_expand(db_input)
  end

end

puts 'Finding more song data on Spotify...' if spotify == true
Spotifyclean::clean(db_input) if spotify == true

puts 'Getting additional info on songs from the Echonest...' if echonest == true
Echonest::echo_search(db_input) if echonest == true

if lyrics == true
  puts 'Starting lyric search...'
  Lyricsearch::primary_lyric_search(db_input)
  puts 'Using alternate methods to improve MetroLyrics searches...'
  Lyricsearch::metro_alt_search(db_input)
  puts 'Using alternate methods to improve Wikia searches...'
  Lyricsearch::wikia_alt_search(db_input)
end

if statistics == true
  song_genres.each do |genre|
    Summarize::singles(genre, db_input)
  end

  if albums == true
    album_genres.each do |genre|
      Summarize::with_albums(genre, db_input)
      Summarize::albums_fetched(genre, db_input)
    end

  end

end

if write == true
  WriteFile::write_songs(song_genres, db_input, origdirectory, write_path)
  WriteFile::write_albums(album_genres, db_input, origdirectory, write_path)
end


rescue => e
  puts e.inspect
  puts e.backtrace

end