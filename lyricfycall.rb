require 'rubygems'
require 'bundler/setup'

require 'Simple-RSS'
require 'Lyricfy'
require 'nokogiri'
require 'yaml'
require 'RSpotify'
require 'json'
require 'sqlite3'

require_relative 'songclass'

metrosuccess = []
wikiasuccess = []

db = SQLite3::Database.open 'albumstest.sqlite'
db.results_as_hash = true

trackfetch = db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE album_id IN (SELECT album_id FROM [R&B/hip hop_albums]) AND ((lyrics_w IS NULL OR lyrics_w != '') AND (lyrics_ml IS NULL OR lyrics_ml != ''))") do |row|
		
	row['songtitle'].gsub!(/\&amp\;/, '&')
	row['songtitle'].gsub!(/\&\#039\;/, '\'')
	row['songtitle'].gsub!(/F\*\*k/, 'Fuck')
	row['songtitle'].gsub!(/S\*\*t/, 'Shit')

	row['artist'].slice!(/.Featuring.*$/)
	row['artist'].slice!(/.With.*$/)
	row['artist'].gsub!(/\&amp\;/, '&')
	row['artist'].gsub!(/\&\#039\;/, '\'')
	row['artist'].gsub!(/"([^"]*)"./, '')

	begin
		puts "#{row['songtitle']} by #{row['artist']}"
		fetcher = Lyricfy::Fetcher.new(:wikia)
		song = fetcher.search "#{row['artist']}", "#{row['songtitle']}"
		songw = song.body("\n")
		db.execute("UPDATE master SET lyrics_w = ? WHERE id = #{row['id']}", "#{songw}")
		puts "Used Wikia successfully"
		wikiasuccess.push(true)
	rescue 
		puts "Can't find #{row['songtitle']} by #{row['artist']} with Wikia."
		next
	end
end

trackfetch = db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE album_id IN (SELECT album_id FROM [R&B/hip hop_albums]) AND ((lyrics_w IS NULL OR lyrics_w != '') AND (lyrics_ml IS NULL OR lyrics_ml != ''))") do |row|
		
	row['songtitle'].delete! '.'
	row['songtitle'].delete! '!'
	row['songtitle'].delete! '#'
	row['songtitle'].delete! '+'
	row['songtitle'].delete! ','
	row['songtitle'].delete! '\''
	row['songtitle'].slice!(/.\(.*$/)
	row['songtitle'].gsub!(/\&amp\;/, '&')
	row['songtitle'].gsub!(/\&\#039\;/, '\'')
	row['songtitle'].gsub!(/F\*\*k/, 'Fuck')
	row['songtitle'].gsub!(/S\*\*t/, 'Shit')

	row['artist'].slice!(/.Featuring.*$/)
	row['artist'].slice!(/.With.*$/)
	row['artist'].slice!(/.\&amp\;.*$/)
	row['artist'].slice!(/,.*$/)
	row['artist'].slice!(/.\&.*$/)
	row['artist'].gsub!(/\$/, 'S')
	row['artist'].delete!('-')
	row['artist'].delete!('\'')
	row['artist'].gsub!(/"([^"]*)"./, '')

	begin
		fetcher2 = Lyricfy::Fetcher.new(:metro_lyrics)
		song2 = fetcher2.search "#{row['artist']}", "#{row['songtitle']}"
		# puts song2.body
		songml = song2.body("\n")
		db.execute("UPDATE master SET lyrics_ml = ? WHERE id = #{row['id']}", "#{songml}")
		metrosuccess.push(true)
	rescue
		puts "I couldn't find lyrics for #{row['songtitle']} by #{row['artist']} on MetroLyrics."
		next
	end
end

stmt = db.execute( "select * from master" )
puts "Total songs: #{stmt.length}"

stmt2 = db.execute( "select * from master WHERE lyrics_w NOTNULL OR lyrics_ml NOTNULL" )
totalfails = (stmt.length.to_i - stmt2.length.to_i)

metrolyricsrate = metrosuccess.count{ |i| i == true }
wikiarate = wikiasuccess.count{ |i| i == true }

puts "Metrolyrics found #{metrolyricsrate} tracks out of #{stmt.length}."
puts "Wikia found #{wikiarate} tracks out of #{stmt.length}."
puts "I couldn't find lyrics for #{totalfails} tracks out of #{stmt.length} total."

