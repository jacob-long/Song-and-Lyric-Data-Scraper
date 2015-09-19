# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'

require 'json'
require 'sqlite3'
require 'RSpotify'
require 'similar_text'

module Spotify_clean

	def clean(dbname)
		db = SQLite3::Database.new(dbname
		db.results_as_hash = true

		# This is private information, do not share!
		RSpotify.authenticate('***REMOVED***', '***REMOVED***')

		# For now, I'm just going to have it select all songs from the master table
		db.execute("SELECT id, songtitle, artist FROM master") do |row|
			begin
				# Eliminating special formatting to improve search results
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

				# Simplifying references to current track info
				artistfetch = row['artist']
				songtitlefetch = row['songtitle']

				# This initiates search to Spotify. 'track' variable is an array of search objects
				track = RSpotify::Track.search("#{artistfetch} #{songtitlefetch}")
				puts "#{songtitlefetch} by #{artistfetch}"
				puts track.inspect

				# Now I will evaluate the quality of the search results. First I create these placeholder variables.
				good_tracks = {}
				chosen_track = nil

				# Iterating through each search result, evaluating how close each one is to the original search query. If it is reasonably close, it is passed to good_songs hash
				track.each_with_index { |value, key|
					artist_score = track[key].artists.first.name.similar("#{artistfetch}")
					title_score = track[key].name.similar("#{songtitlefetch}")
					if artist_score > 75 && title_score > 75
						good_tracks[key] = artist_score+title_score
					else
						next
					end
				}

				# This prevents albums with no close matches from having the wrong data inserted into database
				if good_tracks == {}
				then
					puts 'No solid match found.'
					next
				else
					# Choosing closest match from search results
					chosen_track = good_tracks.max
					chosen_track = chosen_track[0]

					# Updating songtitle/alt_songtitle
					begin
						storig = db.execute("SELECT songtitle FROM master WHERE id = ?", "#{row['id']}")
						if track[chosen_track].name.downcase != storig.first['songtitle'].downcase
							then
							db.execute("UPDATE master SET alt_songtitle = ? WHERE id = ?", "#{track[chosen_track].name}", "#{row['id']}")
						else end
					rescue SQLite3::ConstraintException => e
						puts e
						next
					end

					# Updating artist/alt_artist
					begin
						aorig = db.execute("SELECT artist FROM master WHERE id = ?", "#{row['id']}")
						if track[chosen_track].artists[0].name.downcase != aorig.first['artist'].downcase
							then
							db.execute("UPDATE master SET alt_artist = ? WHERE id = ?", "#{track[chosen_track].artists.first.name}", "#{row['id']}")
						else end
					rescue SQLite3::ConstraintException => e
						puts e
						next
					end

					# Grabbing album and other identifying info, putting into tables
					db.execute("UPDATE master SET album_title = ? WHERE id = ?", "#{track[chosen_track].album.name}", "#{row['id']}")
					db.execute("UPDATE master SET spotify_album_id = ? WHERE id = ?", "#{track[chosen_track].album.id}", "#{row['id']}")
					db.execute("UPDATE master SET spotifyid = ? WHERE id = ?", "#{track[chosen_track].id}", "#{row['id']}")
					db.execute("UPDATE master SET ISRC = ? WHERE id = ?", "#{track[chosen_track].external_ids['isrc']}", "#{row['id']}")
				end

			rescue Encoding::InvalidByteSequenceError => e
				p $!      #=> #<Encoding::InvalidByteSequenceError: "\xA1" followed by "\xFF" on EUC-JP>
				puts e.inspect
				next
			rescue RestClient::ResourceNotFound => e
				puts e
				next
			rescue StandardError => e
				puts "Couldn't find #{songtitlefetch} by #{artistfetch}"
				puts e
				next
			end
		end
	end
end