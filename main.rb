require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'wannabe_bool'
require 'discogs-wrapper'
require 'yaml'

require_relative 'lib/linkfeeder'
require_relative 'lib/linkclass'
require_relative 'lib/dbcalls'
require_relative 'lib/chart_parse'
require_relative 'lib/discogsapi'
require_relative 'lib/spotify'
require_relative 'lib/lyricsearch'
require_relative 'lib/statistics'

instructs_location = ARGV
instructs_location = "config.yaml" if instructs_location == nil
instructs_location = instructs_location.join if instructs_location.is_a? Array
# instructs = File.open(instructs_location, 'r')
# instructs = instructs.readlines
args = YAML.load(File.open(instructs_location))

begin

# This creates the database. It will overwrite in case of a naming conflict if 'overwrite' is set to 'true'.
DBNAME = "#{args['db_path']}"
DB = SQLite3::Database.new(DBNAME)
DBcalls::create_table_master
DB.results_as_hash = true

if args['songs']['scrape'] == true
  # This creates an object of objects of link type (think about that for a minute)
  feed = Feeder.new(args['songs']['genres'], args['years'])
  feed.feed

  # Now I'm sending all of those pre-built links to the parsing method that goes to the site and scrapes the data
  fed = Parse.new(feed)
  fed.chart_parse_songs
end

if args['albums']['run'] == true

  if args['albums']['scrape'] == true
    # This creates an object of objects of link type (think about that for a minute)
    feed2 = Feeder.new(args['albums']['genres'], args['years'])
    feed2.feed_albums

    DBcalls::create_album_master
    fed2 = Parse.new(feed2)
    fed2.chart_parse_albums
  end

  if args['discogs'] == true
    puts 'Getting tracklists for albums from Discogs...'
    DiscogsAPI::get_tracklists(args['db_path'],
                               args['discogs']['token'])
  end

  if args['spotify']['get_tracklists'] == true
    puts 'Getting tracklists for albums from Spotify...'
    Spotifyclean::get_album_ids(args['db_path'], 
                              args['spotify']['client_key'],
                              args['spotify']['secret_key'])
    Spotifyclean::album_expand(args['db_path'], 
                              args['spotify']['client_key'],
                              args['spotify']['secret_key'])
  end

  if args['albums']['statistics'] == true
    args['albums']['genres'].each do |genre|
      Summarize::with_albums(genre, args['db_path'])
      Summarize::albums_fetched(genre, args['db_path'])
    end
  end

end

if args['spotify']['get_metadata'] == true
  puts 'Finding more song data on Spotify...' 
  Spotifyclean::clean(args['db_path'], 
                      args['spotify']['client_key'],
                      args['spotify']['secret_key'],
                      args['spotify']['re_run']) 
end

if args['spotify']['get_ids'] == true
  puts 'Finding Spotify song IDs...' 
  Spotifyclean::get_ids(args['db_path'], 
                      args['spotify']['client_key'],
                      args['spotify']['secret_key'],
                      args['spotify']['re_run']) 
end

if args['spotify']['get_attributes'] == true
  puts "Getting song attributes from Spotify..." 
  Spotifyclean::echo_search(args['db_path'], 
                      args['spotify']['client_key'],
                      args['spotify']['secret_key'],
                      args['spotify']['re_run']) 
end

if args['songs']['lyrics']['search'] == true

  if args['songs']['lyrics']['metrolyrics'] == true
    puts 'Starting MetroLyrics search...'
    Lyricsearch::metro_search(args['db_path'])
    if args['songs']['lyrics']['alt_search'] == true
      puts 'Searching MetroLyrics with alternate metadata...'
      Lyricsearch::metro_alt_search(args['db_path'])
    end
  end

  if args['songs']['lyrics']['wikia'] == true
    puts 'Starting Wikia search...'
    Lyricsearch::wikia_search(args['db_path'])
    if args['songs']['lyrics']['alt_search'] == true
      puts 'Searching Wikia with alternate metadata...'
      Lyricsearch::wikia_alt_search(args['db_path'])
    end
  end
  
end

rescue => e
  puts e.inspect
  puts e.backtrace

end