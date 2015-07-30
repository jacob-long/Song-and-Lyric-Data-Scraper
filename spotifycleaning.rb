# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'

require 'json'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'date'
require 'RSpotify'

DBNAME = "finaldata.sqlite"

begin
DB = SQLite3::Database.new( DBNAME )
rescue StandardError => e
	puts e
end

DB.results_as_hash = true

RSpotify.authenticate("***REMOVED***", "***REMOVED***")

DB.execute("SELECT id, songtitle, artist FROM master") do |row|
	begin

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

		artistfetch = row['artist']
		songtitlefetch = row['songtitle']

		track = RSpotify::Track.search("#{artistfetch} #{songtitlefetch}")
		puts "#{songtitlefetch} by #{artistfetch}"
		# puts track[0].inspect
		puts track[0].artists.first.name
		puts track[0].name

		#Updating tables
		begin
			storig = DB.execute("SELECT songtitle FROM master WHERE id = ?", "#{row['id']}")
			if track[0].name.downcase != storig.first['songtitle'].downcase
				then
				DB.execute("UPDATE master SET alt_songtitle = ? WHERE id = ?", "#{track[0].name}", "#{row['id']}")
			else end
		rescue SQLite3::ConstraintException => e
			puts e
			next
		end

		begin
			aorig = DB.execute("SELECT artist FROM master WHERE id = ?", "#{row['id']}")
			if track[0].artists[0].name.downcase != aorig.first['artist'].downcase
				then
				DB.execute("UPDATE master SET alt_artist = ? WHERE id = ?", "#{track[0].artists.first.name}", "#{row['id']}")
			else end
		rescue SQLite3::ConstraintException => e
			puts e
			next
		end

		DB.execute("UPDATE master SET album_title = ? WHERE id = ?", "#{track[0].album.name}", "#{row['id']}")
		DB.execute("UPDATE master SET spotify_album_id = ? WHERE id = ?", "#{track[0].album.id}", "#{row['id']}")
		DB.execute("UPDATE master SET spotifyid = ? WHERE id = ?", "#{track[0].id}", "#{row['id']}")
		DB.execute("UPDATE master SET ISRC = ? WHERE id = ?", "#{track[0].external_ids['isrc']}", "#{row['id']}")
	# rescue Encoding::InvalidByteSequenceError => e
 #  		p $!      #=> #<Encoding::InvalidByteSequenceError: "\xA1" followed by "\xFF" on EUC-JP>
 #  		puts e.inspect
 #  		next
  	rescue RestClient::ResourceNotFound => e
  		puts e
  	# 	next
  	rescue StandardError => e
  		puts "Couldn't find #{songtitlefetch} by #{artistfetch}"
  		puts e
  		next
  	end
end	