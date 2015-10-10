# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'

require 'json'
require 'sqlite3'
require 'RSpotify'
require 'similar_text'

require_relative 'metaclean'

module Spotifyclean

	def self.clean(dbname)
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		# This is private information, do not share!
		RSpotify.authenticate('***REMOVED***', '***REMOVED***')

		# For now, I'm just going to have it select all songs from the master table
		db.execute("SELECT id, songtitle, artist, spotifyid FROM master WHERE alt_songtitle IS NULL AND alt_artist IS NULL AND spotify_album_id IS NULL") do |row|
			begin
				# Eliminating special formatting to improve search results
				Metaclean::artist_clean(row['artist'])
				Metaclean::title_clean(row['songtitle'])

				# Simplifying references to current track info
				artistfetch = row['artist']
				songtitlefetch = row['songtitle']

				# This initiates search to Spotify. 'track' variable is an array of search objects
				if row['spotifyid'] == nil || row['spotifyid'] == ''
				track = RSpotify::Track.search("#{artistfetch} #{songtitlefetch}")

				artistfetch = row['artist'].downcase
				songtitlefetch = row['songtitle'].downcase

				# Now I will evaluate the quality of the search results. First I create these placeholder variables.
				good_tracks = {}
				duds = {}
				chosen_track = nil

				# Iterating through each search result, evaluating how close each one is to the original search query. If it is reasonably close, it is passed to good_songs hash
				track.each_with_index { |value, key|
					artist_temp = Metaclean::artist_clean(track[key].artists.first.name).downcase
					artist_score = artist_temp.similar("#{artistfetch}")
					title_temp = Metaclean::title_clean(track[key].name).downcase
					title_score = title_temp.similar("#{songtitlefetch}")
					if artist_score > 75 && title_score > 60
						good_tracks[key] = artist_score+title_score
					else
						duds[key] = artist_score+title_score
						next
					end
				}

				# This prevents tracks with no close matches from having the wrong data inserted into database
				if good_tracks == {}
				then
					puts "No solid match found on Spotify for #{songtitlefetch} by #{artistfetch}."
					# top_dud = duds.max
					# puts "Closest match was #{duds[top_dud]}"
					next
				else
					# Choosing closest match from search results
					max_val = good_tracks.values.max
					best_tracks = good_tracks.select {|k,v| v == max_val}.keys.sort
					chosen_track = best_tracks[0]

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


					# Grabbing album and other identifying info, putting into tables
					db.execute("UPDATE master SET album_title = ? WHERE id = ?", "#{track[chosen_track].album.name}", "#{row['id']}")
					db.execute("UPDATE master SET spotify_album_id = ? WHERE id = ?", "#{track[chosen_track].album.id}", "#{row['id']}")
					db.execute("UPDATE master SET spotifyid = ? WHERE id = ?", "#{track[chosen_track].id}", "#{row['id']}")
					db.execute("UPDATE master SET ISRC = ? WHERE id = ?", "#{track[chosen_track].external_ids['isrc']}", "#{row['id']}")

					rescue SQLite3::ConstraintException => e
						puts e
						f = File.open("dupes.txt", "a")
						f.write "#{track[chosen_track].album.name} - #{track[chosen_track].artists.first.name} ... song id = #{row['id']}\n"
						next
					end

					# adding album_id in master to songs from singles charts that have matching albums in the database
					begin
						# prevents SQL lookup errors due to apostrophe
						trackname = track[chosen_track].name.gsub(/''/, '\'')
						artistname = track[chosen_track].artists.first.name.gsub(/''/, '\'')
						albname = track[chosen_track].album.name.gsub(/''/, '\'')
						albid = track[chosen_track].album.id


						# grabbing album_id if it exists
						# noinspection RubyQuotedStringsInspection
						preidstmt = db.prepare("SELECT id FROM album_master WHERE spotifyid = ? OR ((albumtitle LIKE ? OR alt_albumtitle LIKE ?) AND artist LIKE ?)")
						preid = preidstmt.execute!("#{albid}", "#{albname}", "#{albname}", "#{artistname}")

						if preid == []
							# If the single's album isn't in album_master, putting it there so I can add their full tracklists too
							putnewidstmt = db.prepare("INSERT INTO album_master(albumtitle, artist, spotifyid, from_single) VALUES (?,?,?,?)")
							putnewidstmt.execute!("#{albname}", "#{artistname}", "#{track[chosen_track].album.id}", "TRUE")
							puts "Created new album entry for #{albname} by #{artistname}"

						else
							db_albid = preid[0][0]

							# attaching album ID from album_master table to master table
							putidstmt = db.prepare("UPDATE master SET album_id = ? WHERE id = ?")
							putidstmt.execute!("#{db_albid}", "#{row['id']}")

						end

					rescue StandardError => e
						puts "Problem looking up or creating album ID for #{trackname} by #{artistname}. Moving on with no ID..."
						puts e.backtrace
						puts preid.inspect
						next
					end

					puts "Found new info for #{songtitlefetch} (found: #{track[chosen_track].name}) by #{artistfetch} (found: #{track[chosen_track].artists.first.name})"
				end

				else
					track = RSpotify::Track.find(row['spotifyid'])

					# Updating songtitle/alt_songtitle
					begin
						storig = db.execute("SELECT songtitle FROM master WHERE id = ?", "#{row['id']}")
						if track.name.downcase != storig.first['songtitle'].downcase
						then
							db.execute("UPDATE master SET alt_songtitle = ? WHERE id = ?", "#{track.name}", "#{row['id']}")
						else end
					rescue SQLite3::ConstraintException => e
						puts e
						next
					end

					# Updating artist/alt_artist
					begin
						aorig = db.execute("SELECT artist FROM master WHERE id = ?", "#{row['id']}")
						if track.artists[0].name.downcase != aorig.first['artist'].downcase
						then
							db.execute("UPDATE master SET alt_artist = ? WHERE id = ?", "#{track.artists.first.name}", "#{row['id']}")
						else end

					# Grabbing album and other identifying info, putting into tables
					db.execute("UPDATE master SET album_title = ? WHERE id = ?", "#{track.album.name}", "#{row['id']}")
					db.execute("UPDATE master SET spotify_album_id = ? WHERE id = ?", "#{track.album.id}", "#{row['id']}")
					db.execute("UPDATE master SET spotifyid = ? WHERE id = ?", "#{track.id}", "#{row['id']}")
					db.execute("UPDATE master SET ISRC = ? WHERE id = ?", "#{track.external_ids['isrc']}", "#{row['id']}")

					rescue SQLite3::ConstraintException => e
						puts e
						f = File.open("dupes.txt", "a")
						f.write "#{track.album.name} - #{track.artists.first.name} ... song id = #{row['id]']}\n"
						next
					end

					# adding album_id in master to songs from singles charts that have matching albums in the database
					begin
					# prevents SQL lookup errors due to apostrophe
					trackname = track.name.gsub(/''/, '\'')
					artistname = track.artists.first.name.gsub(/''/, '\'')
					albname = track.album.name.gsub(/''/, '\'')
					albid = track.album.id

						# grabbing album_id if it exists
						# noinspection RubyQuotedStringsInspection
						preidstmt = db.prepare("SELECT id FROM album_master WHERE spotifyid = ? OR ((albumtitle LIKE ? OR alt_albumtitle LIKE ?) AND artist LIKE ?)")
						preid = preidstmt.execute!("#{albid}", "#{albname}", "#{albname}", "#{artistname}")
						if preid != nil && preid != []
							db_albid = preid[0][0]

							# attaching album ID from album_master table to master table
							putidstmt = db.prepare("UPDATE master SET album_id = ? WHERE id = ?")
							putidstmt.execute!("#{db_albid}", "#{row['id']}")

							# If the single's album isn't in album_master, putting it there so I can add their full tracklists too
						else
							putnewidstmt = db.prepare("INSERT INTO album_master(albumtitle, artist, spotifyid, from_single) VALUES (?,?,?,?)")
							putnewidstmt.execute!("#{albname}", "#{artistname}", "#{track.album.id}", "TRUE")
							puts "Created new album entry for #{albname} by #{artistname}"
						end

					rescue StandardError => e
						puts "Problem looking up or creating album ID for #{trackname} by #{artistname}. Moving on with no ID..."
						puts e
						puts e.backtrace
						puts preid.inspect
						next
					end

					puts "Found new info for #{songtitlefetch} (found: #{track.name}) by #{artistfetch} (found: #{track.artists.first.name})"
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
				puts e.backtrace
				next
			end
		end
	end

	def self.album_expand(dbname)

		# This is private information, do not share!
		RSpotify.authenticate('***REMOVED***', '***REMOVED***')

		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		db.execute("SELECT id, spotifyid, albumtitle FROM album_master WHERE discogsid IS NULL AND spotify_run IS NULL AND (spotifyid NOT NULL AND spotifyid != 'None') AND from_single IS NULL") do |album|
			begin

			result = RSpotify::Album.find(album['spotifyid'])

			result.tracks.each do |track|
				begin
				statement = db.prepare("INSERT INTO master (songtitle, artist, album_id, spotifyid, spotify_album_id, num_on_album, from_album_chart) VALUES (?, ?, ?, ?, ?, ?, ?)")
				statement.execute(track.name, track.artists.first.name, album['id'], track.id, album['spotifyid'], track.track_number, 'true')

				rescue SQLite3::ConstraintException => e
				puts e
					id = db.execute("SELECT id FROM master WHERE artist LIKE ? AND songtitle LIKE ?", track.artists.first.name, track.name)
					id = id[0]
					db.execute("UPDATE master SET album_id = ? WHERE id = ?", "#{album['id']}", "#{id}")
					db.execute("UPDATE master SET spotify_album_id = ? WHERE id = ?", "#{album['spotifyid']}", "#{id}")
					db.execute("UPDATE master SET num_on_album = ? WHERE id = ?", "#{track.track_number}", "#{id}")
					db.execute("UPDATE master SET album_title = ? WHERE id = ?", "#{album['albumtitle']}", "#{id}")
					puts "Updated original entry instead."
				end

			end

			rescue => e
				puts e
				puts e.backtrace
				puts "Some kind of problem! Moving on to the next album..."
				db.execute("UPDATE album_master SET spotify_run = 'true' WHERE id = ?", album['id'])
				next
			end

			puts "Found tracklist with Spotify successfully."
			db.execute("UPDATE album_master SET spotify_run = 'true' WHERE id = ?", album['id'])
		end
	end
end