require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'fileutils'



module WriteFile

	def self.write_songs(genres, dbname, root, path)
		Dir.chdir("#{root}")
		db = SQLite3::Database.new(dbname)
		db.results_as_hash = true

		# Iterating through each genre
		genres.each do |genre|

			# Grabbing all qualifying songs
			Dir.chdir("#{root}")
			songids = db.execute("SELECT DISTINCT song_id from [#{genre}]")
			puts genre
			# This is so as not to break certain file systems with extra slashes
			genre1 = genre.delete('/')

			# Creating a folder just for that genre, then changing working directory to that folder
			FileUtils::mkdir_p "#{path}/#{genre1}"
			Dir.chdir("#{path}/#{genre1}")

			# Iterating through each song
			songids.each do |songid|
				# Selecting info from the database
				songs = db.execute("SELECT songtitle, artist, lyrics_ml, lyrics_w FROM master WHERE id = ? AND ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != ''))", songid['song_id'])

				# Making sure a result is found
				if songs.count == 1

					# Writing all songs to common file
					then
					f = File.open("#{genre1}all.txt", "a")

					# Preferring MetroLyrics if I have it
					if songs[0]['lyrics_ml'] != nil && songs[0]['lyrics_ml'] != ''
						then
						lyrics = songs[0]['lyrics_ml']
						f.write "[NewSong]\n\n#{lyrics}\n\n"
					elsif songs[0]['lyrics_w'] != nil && songs[0]['lyrics_w'] != ''
						lyrics = songs[0]['lyrics_w']
						f.write "[NewSong]\n\n#{lyrics}\n\n"

					# Just in case
					else
						puts "I only have blank lyrics for #{songs['songtitle']} by #{songs['artist']}."
					end

				# If there are no lyrics, go to the next song
				else
					next
				end
			end
		end
	end

	def self.write_albums(genres, dbname, root, path)
		Dir.chdir("#{root}")
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		# Iterating through genres
		genres.each do |genre|

			# Setting working directory to root folder, grabbing songs from genre table
			Dir.chdir("#{root}")
			albids = db.execute("SELECT DISTINCT album_id from [#{genre}_albums]")
			puts genre
			genre1 = genre.delete('/')

			# Creating directory for the genre, switching to it
			FileUtils::mkdir_p "#{path}/#{genre1}"
			Dir.chdir("#{path}/#{genre1}")

			# Grabbing tracks for each album
			albids.each do |albid|
				songs = db.execute("SELECT songtitle, artist, lyrics_ml, lyrics_w FROM master WHERE album_id = ? AND ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != '') AND from_album_chart != 'true')", albid['album_id'])

				# Making sure there is at least 1 qualifying song
				if songs.count >= 1
					then

					# Adding everything to common file
					f = File.open("#{genre1}all.txt", "a")

					# Iterating through each song
					songs.each do |thesong|
						if thesong['lyrics_ml'] != nil && thesong['lyrics_ml'] != ''
							then
							lyrics = thesong['lyrics_ml']
							f.write "[NewSong]\n\n#{lyrics}\n\n"
						elsif thesong['lyrics_w'] != nil && thesong['lyrics_w'] != ''
							lyrics = thesong['lyrics_w']
							f.write "[NewSong]\n\n#{lyrics}\n\n"
						else
							puts "I only have blank lyrics for #{songs['songtitle']} by #{songs['artist']}."
							next
						end
					end

				# If there are no lyrics, move on to the next album
				else
					next
				end
			end
		end
	end

end

