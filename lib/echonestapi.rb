require 'rubygems'
require 'bundler/setup'

require 'Echowrap'
require 'sqlite3'
require 'nokogiri'
require 'open-uri'
require 'json/pure'

module Echonest

def self.echo_search(dbname)
	db = SQLite3::Database.open( dbname )

	# Echo Nest API keys and such, don't share with public
	Echowrap.configure do |config|
		config.api_key =       'UQHQ5ON6UJ3FXV4UB'
		config.consumer_key =  'b4a21f70d81680d02d4f8390225d1986'
		config.shared_secret = 'iebmiY4TRIaiUI08HjpqdQ'
	end

	# The following loops through each row in the database, then passing it to Echo Nest API,
	# which writes its various outputs to the specified columns in the database

	db.results_as_hash = true
	db.execute(" SELECT id, artist, songtitle FROM master WHERE echonest_run IS NULL AND id > 34287") do |x|
		# Cleaning songtitles using same string manipulations as lyric search script
		x['songtitle'].delete! '.'
		x['songtitle'].delete! '!'
		x['songtitle'].delete! '#'
		x['songtitle'].delete! '+'
		x['songtitle'].delete! ','
		x['songtitle'].delete! '\''
		x['songtitle'].slice!(/.\(.*$/)
		x['songtitle'].gsub!(/\&amp\;/, '&')
		x['songtitle'].gsub!(/\&\#039\;/, '\'')
		x['songtitle'].gsub!(/F\*\*k/, 'Fuck')
		x['songtitle'].gsub!(/S\*\*t/, 'Shit')

		# Cleaning artists using same string manipulations as lyric search script
		x['artist'].slice!(/.Featuring.*$/)
		x['artist'].slice!(/.With.*$/)
		x['artist'].slice!(/.\&amp\;.*$/)
		x['artist'].slice!(/,.*$/)
		x['artist'].slice!(/.\&.*$/)
		x['artist'].gsub!(/\$/, 'S')
		x['artist'].delete!('-')
		x['artist'].delete!('\'')
		x['artist'].gsub!(/"([^"]*)"./, '')

		# Dealing with rate limit
		sleep(0.5)

		# Showing progress
		puts
		puts x['id']

		good_tracks = {}
		chosen_track = nil

		# Initiating the search
		song = Echowrap.song_search(:artist => x['artist'], :title => x['songtitle'], :bucket => ['audio_summary', 'artist_location'], :results => 5)
		song.each_with_index do |value, key|

			artist_score = song[key].artist_name.similar("#{x['artist']}")
			title_score = song[key].title.similar("#{x['songtitle']}")
			if artist_score > 75 && title_score > 60
				good_tracks[key] = artist_score+title_score
			else
				next
			end
		end

		# This prevents albums with no close matches from having the wrong data inserted into database
		if good_tracks == {}
		then
			puts 'No solid match found.'
			db.execute("UPDATE master SET echonest_run = 'true' WHERE id = '#{x['id']}'")
			next
		else
			# Choosing closest match from search results
			max_val = good_tracks.values.max
			best_tracks = good_tracks.select {|k,v| v == max_val}.keys.sort
			chosen_track = best_tracks[0]

			# This puts the closest match's data in the database
			begin
				puts 'Found it!'
				puts song[chosen_track].inspect
				# The convoluted syntax is necessary because I'm updating an existing data table.
				db.execute_batch("
					UPDATE master SET echonest_id ='#{song[chosen_track].id.to_s}' WHERE id='#{x['id']}';
					UPDATE master SET key ='#{song[chosen_track].audio_summary.key}' WHERE id='#{x['id']}';
					UPDATE master SET energy ='#{song[chosen_track].audio_summary.energy}' WHERE id='#{x['id']}';
					UPDATE master SET liveness ='#{song[chosen_track].audio_summary.liveness}' WHERE id='#{x['id']}';
					UPDATE master SET loudness ='#{song[chosen_track].audio_summary.loudness}' WHERE id='#{x['id']}';
					UPDATE master SET valence ='#{song[chosen_track].audio_summary.valence}' WHERE id='#{x['id']}';
					UPDATE master SET danceability ='#{song[chosen_track].audio_summary.danceability}' WHERE id='#{x['id']}';
					UPDATE master SET tempo ='#{song[chosen_track].audio_summary.tempo}' WHERE id='#{x['id']}';
					UPDATE master SET speechiness ='#{song[chosen_track].audio_summary.speechiness}' WHERE id='#{x['id']}';
					UPDATE master SET acousticness ='#{song[chosen_track].audio_summary.acousticness}' WHERE id='#{x['id']}';
					UPDATE master SET mode ='#{song[chosen_track].audio_summary.mode}' WHERE id='#{x['id']}';
					UPDATE master SET time_signature ='#{song[chosen_track].audio_summary.time_signature}' WHERE id='#{x['id']}';
					UPDATE master SET duration ='#{song[chosen_track].audio_summary.duration}' WHERE id='#{x['id']}';
					UPDATE master SET analysis_url ='#{song[chosen_track].audio_summary.analysis_url}' WHERE id='#{x['id']}';
					UPDATE master SET instrumentalness ='#{song[chosen_track].audio_summary.instrumentalness}' WHERE id='#{x['id']}';
					UPDATE master SET artist_location ='#{song[chosen_track].artist_location.location}' WHERE id='#{x['id']}';
				")

				db.execute("UPDATE master SET echonest_run = 'true' WHERE id = '#{x['id']}'")

				# This grabs the detailed analysis from the link embedded in the search result
				analysis_url = song[chosen_track].audio_summary.analysis_url
				# sleep(3) - not needed because my API rate limit was lifted. Use if you are rate limited
				jsonobject = open(analysis_url)
				analysis_parse = JSON.parse(jsonobject.first)

				# This adds additional data from the JSON analysis document.
				db.execute_batch("
					UPDATE master SET key_confidence ='#{analysis_parse['track']['key_confidence']}' WHERE id='#{x['id']}';
					UPDATE master SET audio_md5 ='#{analysis_parse['track']['audio_md5']}' WHERE id='#{x['id']}';
					UPDATE master SET tempo_confidence ='#{analysis_parse['track']['tempo_confidence']}' WHERE id='#{x['id']}';
					UPDATE master SET mode_confidence ='#{analysis_parse['track']['mode_confidence']}' WHERE id='#{x['id']}';
					UPDATE master SET time_signature_confidence ='#{analysis_parse['track']['time_signature_confidence']}' WHERE id='#{x['id']}';
				")

			rescue NoMethodError => e
				puts e.backtrace
				puts e
				puts song.inspect
				db.execute("UPDATE master SET echonest_run = 'true' WHERE id = '#{x['id']}'")
			rescue => e
				puts e.message
				puts e.backtrace.inspect
				puts song.inspect
				puts analysis_url
				puts jsonobject.inspect
				puts "Problem with #{x['songtitle']} by #{x['artist']}. Moving on..."
				db.execute("UPDATE master SET echonest_run = 'true' WHERE id = '#{x['id']}'")
				next
			end
		end
	end
end
end