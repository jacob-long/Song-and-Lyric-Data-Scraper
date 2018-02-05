# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'

require 'json'
require 'sqlite3'
require 'RSpotify'
require 'similar_text'

require_relative 'metaclean'

module Spotifyclean

	def self.clean(dbname, spotify_client, spotify_secret, rerun = false)
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		# This is private information, do not share!
		RSpotify.authenticate(spotify_client, spotify_secret)

		# For now, I'm just going to have it select all songs from the master table
		if rerun == false
			songs = db.execute("SELECT id, songtitle, artist, spotifyid FROM master WHERE 
								alt_songtitle IS NULL AND alt_artist IS NULL AND
								spotify_song_run IS NULL")
		else
			songs = db.execute("SELECT id, songtitle, artist, spotifyid FROM master WHERE 
								alt_songtitle IS NULL AND alt_artist IS NULL")
		end
		
		prog_bar = ProgressBar.create(:title => "Spotify metadata search progress",
									  :starting_at => 0,
									  :total => songs.length)
		
		songs.each do |row|
			begin
				# Eliminating special formatting to improve search results
				artistfetch = Metaclean::artist_clean(row['artist'])
				songtitlefetch = Metaclean::title_clean(row['songtitle'])

				# This initiates search to Spotify. 'track' variable is an array of search objects
				begin
					if row['spotifyid'] == nil || row['spotifyid'] == ''
				
						track = no_id_search(row, artistfetch, songtitlefetch)

					else
					
						track = id_search(row)

					end
				rescue Encoding::InvalidByteSequenceError => e
					# p $!      #=> #<Encoding::InvalidByteSequenceError: "\xA1" followed by "\xFF" on EUC-JP>
					prog_bar.log e.inspect
					prog_bar.log "Some kind of encoding problem with #{songtitlefetch} by"\
								 " #{artistfetch}. Skipping to the next song..."
					db.execute("UPDATE master SET spotify_song_run = 'error' WHERE id = ?", "#{row['id']}")
					prog_bar.increment
					next
				rescue RestClient::ResourceNotFound => e
					prog_bar.log e
					prog_bar.log "Some kind of connection issue while getting #{songtitlefetch} by"\
								 " #{artistfetch}. Skipping to the next song..."
					db.execute("UPDATE master SET spotify_song_run = 'error' WHERE id = ?", "#{row['id']}")
					prog_bar.increment
					next
				rescue StandardError => e
					# puts "Couldn't find #{songtitlefetch} by #{artistfetch}"
					prog_bar.log e
					prog_bar.log "Something went wrong with #{songtitlefetch} by #{artistfetch}."\
								"Skipping to the next song..."
					db.execute("UPDATE master SET spotify_song_run = 'error' WHERE id = ?", "#{row['id']}")
					prog_bar.increment
					next
				end

				if track == nil
					prog_bar.increment
					next
				end

				# Updating songtitle/alt_songtitle
				storig = db.execute("SELECT songtitle FROM master WHERE id = ?", "#{row['id']}")
				if track.name.downcase != storig.first['songtitle'].downcase
					db.execute("UPDATE master SET alt_songtitle = ? WHERE id = ?", "#{track.name}", "#{row['id']}")
				else end

			rescue SQLite3::ConstraintException => e
				prog_bar.log e
				prog_bar.log "It looks like #{songtitlefetch} by #{artistfetch} might be a duplicate."\
							"Skipping to the next song without entering new data..."
				db.execute("UPDATE master SET spotify_song_run = 'duplicate' WHERE id = ?", "#{row['id']}")
				prog_bar.increment
				next
			end

			# Updating artist/alt_artist
			begin
				aorig = db.execute("SELECT artist FROM master WHERE id = ?", "#{row['id']}")
				if track.artists[0].name.downcase != aorig.first['artist'].downcase
					db.execute("UPDATE master SET alt_artist = ? WHERE id = ?",
					 			"#{track.artists.first.name}", "#{row['id']}")
				else end


				# Grabbing album and other identifying info, putting into tables
				db.execute("UPDATE master SET album_title = ? WHERE id = ?",
				 			"#{track.album.name}", "#{row['id']}")
				db.execute("UPDATE master SET spotify_album_id = ? WHERE id = ?",
							"#{track.album.id}", "#{row['id']}")
				db.execute("UPDATE master SET spotifyid = ? WHERE id = ?",
							"#{track.id}", "#{row['id']}")
				db.execute("UPDATE master SET ISRC = ? WHERE id = ?",
							"#{track.external_ids['isrc']}", "#{row['id']}")

			rescue SQLite3::ConstraintException => e
				prog_bar.log e
				prog_bar.log "It looks like #{songtitlefetch} by #{artistfetch} might be a duplicate."\
							"Skipping to the next song without entering new data..."
				db.execute("UPDATE master SET spotify_song_run = 'duplicate' WHERE id = ?", "#{row['id']}")
				prog_bar.increment
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
				preidstmt = db.prepare("SELECT id FROM album_master WHERE spotifyid = ? OR
				 					    ((albumtitle LIKE ? OR alt_albumtitle LIKE ?) AND artist LIKE ?)")
				preid = preidstmt.execute!("#{albid}", "#{albname}", "#{albname}", "#{artistname}")

				if preid == []
					# If the single's album isn't in album_master, putting it there so I can add their full tracklists too
					putnewidstmt = db.prepare("INSERT INTO album_master(albumtitle, artist, spotifyid, from_single) VALUES (?,?,?,?)")
					putnewidstmt.execute!("#{albname}", "#{artistname}", "#{track.album.id}", "TRUE")

				else
					db_albid = preid[0][0]
					# attaching album ID from album_master table to master table
					putidstmt = db.prepare("UPDATE master SET album_id = ? WHERE id = ?")
					putidstmt.execute!("#{db_albid}", "#{row['id']}")

				end

			rescue StandardError => e
				prog_bar.log e
				prog_bar.log "Problem looking up or creating album ID for #{trackname} by #{artistname}. Moving on with no ID..."
				prog_bar.increment
				next
			end

			prog_bar.increment

		end
	end

	def self.album_expand(dbname, spotify_client, spotify_secret, rerun = false)
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		# This is private information, do not share!
		RSpotify.authenticate(spotify_client, spotify_secret)

		albums = db.execute("SELECT id, spotifyid, albumtitle FROM album_master WHERE
							 discogsid IS NULL AND spotify_run IS NULL AND spotifyid NOT NULL 
							 AND from_single IS NULL")

		prog_bar = ProgressBar.create(:title => "Spotify album tracklist progress",
							 		  :starting_at => 0,
							 		  :total => albums.length) 
		
		albums.each do |album|
			begin

			result = RSpotify::Album.find(album['spotifyid'])

			result.tracks.each do |track|
				begin
				statement = db.prepare("INSERT INTO master (songtitle, artist, album_id, spotifyid, spotify_album_id, num_on_album, from_album_chart) VALUES (?, ?, ?, ?, ?, ?, ?)")
				statement.execute(track.name, track.artists.first.name, album['id'], track.id, album['spotifyid'], track.track_number, 'true')

				rescue SQLite3::ConstraintException => e
					prog_bar.log e
					id = db.execute("SELECT id FROM master WHERE artist LIKE ? AND songtitle LIKE ?", track.artists.first.name, track.name)
					id = id[0]
					db.execute("UPDATE master SET album_id = ? WHERE id = ?", "#{album['id']}", "#{id}")
					db.execute("UPDATE master SET spotify_album_id = ? WHERE id = ?", "#{album['spotifyid']}", "#{id}")
					db.execute("UPDATE master SET num_on_album = ? WHERE id = ?", "#{track.track_number}", "#{id}")
					db.execute("UPDATE master SET album_title = ? WHERE id = ?", "#{album['albumtitle']}", "#{id}")
				end

			end

			rescue => e
				prog_bar.log e
				# prog_bar.log e.backtrace
				prog_bar.log "Some kind of problem! Moving on to the next album..."
				db.execute("UPDATE album_master SET spotify_run = 'true' WHERE id = ?", album['id'])
				prog_bar.increment
				next
			end

			db.execute("UPDATE album_master SET spotify_run = 'true' WHERE id = ?", album['id'])
			prog_bar.increment

		end
	end

	def self.get_ids(dbname, spotify_client, spotify_secret)
		
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		# This is private information, do not share!
		RSpotify.authenticate(spotify_client, spotify_secret)

		# For now, I'm just going to have it select all matching songs from the master table
		songs = db.execute("SELECT id, songtitle, artist FROM master WHERE 
							spotifyid IS NULL")
		
		prog_bar = ProgressBar.create(:title => "Spotify ID search progress",
									  :starting_at => 0,
									  :total => songs.length)
		
		songs.each do |row|

			begin
				# Eliminating special formatting to improve search results
				artistfetch = Metaclean::artist_clean(row['artist'])
				songtitlefetch = Metaclean::title_clean(row['songtitle'])

				track = no_id_search(row, artistfetch, songtitlefetch)

			rescue Encoding::InvalidByteSequenceError => e
				# p $!      #=> #<Encoding::InvalidByteSequenceError: "\xA1" followed by "\xFF" on EUC-JP>
				prog_bar.log e.inspect
				prog_bar.increment
				next
			rescue RestClient::ResourceNotFound => e
				prog_bar.log e
				prog_bar.increment
				next
			rescue StandardError => e
				prog_bar.log e
				prog_bar.increment
				next
			end

			db.execute("UPDATE master SET spotifyid = ? WHERE id = ?",
							"#{track.id}", "#{row['id']}")
			prog_bar.increment

		end

	end

	def self.get_album_ids(dbname, spotify_client, spotify_secret)
		
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		# This is private information, do not share!
		RSpotify.authenticate(spotify_client, spotify_secret)

		# For now, I'm just going to have it select all matching songs from the master table
		albums = db.execute("SELECT id, albumtitle, artist FROM album_master WHERE 
							spotifyid IS NULL")
		
		prog_bar = ProgressBar.create(:title => "Spotify ID search progress",
									  :starting_at => 0,
									  :total => albums.length)
		
		albums.each do |row|

			begin
				# Eliminating special formatting to improve search results
				artistfetch = Metaclean::artist_clean(row['artist'])
				albumtitlefetch = Metaclean::title_clean(row['albumtitle'])

				track = no_id_search(row, artistfetch, albumtitlefetch, true)

			rescue Encoding::InvalidByteSequenceError => e
				# p $!      #=> #<Encoding::InvalidByteSequenceError: "\xA1" followed by "\xFF" on EUC-JP>
				prog_bar.log e.inspect
				prog_bar.increment
				next
			rescue RestClient::ResourceNotFound => e
				prog_bar.log e
				prog_bar.increment
				next
			rescue StandardError => e
				prog_bar.log e
				prog_bar.increment
				next
			end

			if track != nil
				begin 
				db.execute("UPDATE album_master SET spotifyid = ? WHERE id = ?",
								"#{track.id}", "#{row['id']}")
				rescue SQLite3::ConstraintException => e
					prog_bar.log "It looks like #{albumtitlefetch} by #{artistfetch} has a "\
								  "duplicate in the database. Skipping album tracklist search..."
					db.execute("UPDATE album_master SET spotifyid = ? WHERE id = ?",
								  "'duplicate'", "#{row['id']}")
					prog_bar.increment
					next
				end
			else end
			prog_bar.increment

		end

	end


	def self.no_id_search(row, artistfetch, songtitlefetch, album = false)
		
		if album == false
			track = RSpotify::Track.search("#{artistfetch} #{songtitlefetch}", limit: 25)
		else
			track = RSpotify::Album.search("#{artistfetch} #{songtitlefetch}", limit: 25)
		end

		artistfetch = artistfetch.downcase
		songtitlefetch = songtitlefetch.downcase

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
			nil
		else
			# Choosing closest match from search results
			max_val = good_tracks.values.max
			best_tracks = good_tracks.select {|k,v| v == max_val}.keys.sort
			chosen_track = best_tracks[0]
			track[chosen_track]
		end

	end

	def self.id_search(row)
	
		track = RSpotify::Track.find(row['spotifyid'])
	
	end

	# "echo_search" retained as name for legacy reasons as these features were
	# once part of The Echo Nest
	def self.echo_search(dbname, spotify_client, spotify_secret, rerun = false)
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		# This is private information, do not share!
		RSpotify.authenticate(spotify_client, spotify_secret)
	
		# The following loops through each row in the database, then passing it to Echo Nest API,
		# which writes its various outputs to the specified columns in the database
	
		db.results_as_hash = true
		if rerun == false 
			songs = db.execute(" SELECT id, artist, songtitle, spotifyid FROM master 
								WHERE attributes_run IS NULL ") 
		else
			songs = db.execute(" SELECT id, artist, songtitle, spotifyid FROM master 
								WHERE duration IS NULL ") # arbitrary attribute that shouldn't be null
		end

		
		prog_bar = ProgressBar.create(:title => "Song attribute search progress",
									  :starting_at => 0,
									  :total => songs.length)
	
		songs.each do |x|
			
			track = RSpotify::AudioFeatures.find(x['spotifyid'])
			if track == nil
				db.execute("UPDATE master SET attributes_run = 'true' WHERE id = '#{x['id']}'")
				prog_bar.increment
				next
			end
	
			# This puts the closest match's data in the database
			begin
			# The convoluted syntax is necessary because I'm updating an existing data table.
			db.execute_batch("
				UPDATE master SET key ='#{track.key}' WHERE id='#{x['id']}';
				UPDATE master SET energy ='#{track.energy}' WHERE id='#{x['id']}';
				UPDATE master SET liveness ='#{track.liveness}' WHERE id='#{x['id']}';
				UPDATE master SET loudness ='#{track.loudness}' WHERE id='#{x['id']}';
				UPDATE master SET valence ='#{track.valence}' WHERE id='#{x['id']}';
				UPDATE master SET danceability ='#{track.danceability}' WHERE id='#{x['id']}';
				UPDATE master SET tempo ='#{track.tempo}' WHERE id='#{x['id']}';
				UPDATE master SET speechiness ='#{track.speechiness}' WHERE id='#{x['id']}';
				UPDATE master SET acousticness ='#{track.acousticness}' WHERE id='#{x['id']}';
				UPDATE master SET mode ='#{track.mode}' WHERE id='#{x['id']}';
				UPDATE master SET time_signature ='#{track.time_signature}' WHERE id='#{x['id']}';
				UPDATE master SET duration ='#{track.duration_ms}' WHERE id='#{x['id']}';
				UPDATE master SET analysis_url ='#{track.analysis_url}' WHERE id='#{x['id']}';
				UPDATE master SET instrumentalness ='#{track.instrumentalness}' WHERE id='#{x['id']}';
			")
	
			db.execute("UPDATE master SET attributes_run = 'true' WHERE id = '#{x['id']}'")
	
			# This grabs the detailed analysis from the link embedded in the search result
			analysis_url = "#{track.analysis_url}?access_token=#{RSpotify.client_token}"
			# sleep(3) - not needed because my API rate limit was lifted. Use if you are rate limited
			jsonobject = open(analysis_url)
			analysis_parse = JSON.parse(jsonobject.first)
	
			# This adds additional data from the JSON analysis document.
			db.execute_batch("
				UPDATE master SET key_confidence ='#{analysis_parse['track']['key_confidence']}' WHERE id='#{x['id']}';
				UPDATE master SET audio_md5 ='#{analysis_parse['track']['audio_md5']}' WHERE id='#{x['id']}';
				UPDATE master SET tempo_confidence ='#{analysis_parse['track']['tempo_confidence']}' WHERE id='#{x['id']}';
				UPDATE master SET mode_confidence ='#{analysis_parse['track']['mode_confidence']}' WHERE id='#{x['id']}';
				UPDATE master SET time_signature_confidence ='#{analysis_parse['track']['time_signature_confidence']}'
				 	WHERE id='#{x['id']}';
			")
	
			prog_bar.increment
	
			rescue NoMethodError => e
				prog_bar.log e
				db.execute("UPDATE master SET attributes_run = 'true' WHERE id = '#{x['id']}'")
			rescue => e
				prog_bar.log e
				prog_bar.log "Problem with #{x['songtitle']} by #{x['artist']}. Moving on..."
				db.execute("UPDATE master SET attributes_run = 'true' WHERE id = '#{x['id']}'")
				prog_bar.increment
				next
			end
			prog_bar.increment
		end
	end

end