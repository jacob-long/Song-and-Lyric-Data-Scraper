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
require_relative 'lib/lyricsearch'
require_relative 'lib/statistics'

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
spotify_client = nil
spotify_secret = nil
lyrics = false
alt_search = false
metro = false
wikia = false
albums = false
overwrite = false
statistics = false

begin

instructs.each_with_index do |line, num|
  if line.match(/^## statistics/)
    statistics = instructs[num+1].strip.to_b
  end
  if line.match(/^## overwrite/)
    overwrite = instructs[num+1].strip.to_b
  end
  if line.match(/^## albums/)
    albums = instructs[num+1].strip.to_b
  end
  if line.match(/^## scrape-albums/)
    scrape_albums = instructs[num+1].strip.to_b
  end
  if line.match(/^## path/)
    write_path = instructs[num+1].strip
  end
  if line.match(/^## write/)
    write = instructs[num+1].strip.to_b
  end
  if line.match(/^## lyric-search/)
    lyrics = instructs[num+1].strip.to_b
  end
  if line.match(/^## wikia-search/)
    wikia = instructs[num+1].strip.to_b
  end
  if line.match(/^## metro-search/)
    metro = instructs[num+1].strip.to_b
  end
  if line.match(/^## alt-search/)
    alt_search = instructs[num+1].strip.to_b
  end
  if line.match(/^## spotify/)
    spotify = instructs[num+1].strip.to_b
  end
  if line.match(/^## client\-key\-spotify/)
    spotify_client = instructs[num+1].strip
  end
  if line.match(/^## secret\-key\-spotify/)
    spotify_secret = instructs[num+1].strip
  end
  if line.match(/^## discogs/)
    discogs = instructs[num+1].strip.to_b
  end
  if line.match(/^## token\-discogs/)
    discogs_token = instructs[num+1].strip
  end
  if line.match(/^## scrape-songs/)
    scrape_songs = instructs[num+1].strip.to_b
  end
  if line.match(/^## song-genres/)
    genre_in = instructs[num+1]
    song_genres = genre_in.split(", ").collect{ |x| x.strip}
  end
  if line.match(/^## album-genres/)
    genre_in = instructs[num+1]
    album_genres = genre_in.split(", ").collect{ |x| x.strip}
  end
  if line.match(/^## years/)
    year_in = instructs[num+1]
    years = year_in.split(", ").collect{ |x| x.strip}
  end
  if line.match(/^## dbname/)
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
Spotifyclean::clean(db_input, spotify_client, spotify_secret) if spotify == true

if lyrics == true

  if metro == true
    puts 'Starting MetroLyrics search...'
    Lyricsearch::metro_search(db_input)
    if alt_search == true
      puts 'Searching MetroLyrics with alternate metadata...'
      Lyricsearch::metro_alt_search(db_input)
    end
  end

  if wikia == true
    puts 'Starting Wikia search...'
    Lyricsearch::wikia_search(db_input)
    if alt_search == true
      puts 'Searching Wikia with alternate metadata...'
      Lyricsearch::wikia_alt_search(db_input)
    end
  end
  
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


rescue => e
  puts e.inspect
  puts e.backtrace

end