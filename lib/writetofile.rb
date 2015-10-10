require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'fileutils'

module WriteFile

	def self.write_songs(genres, dbname, root, path)
		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		genres.each do |genre|
			Dir.chdir("#{root}")
			puts root

			songids = db.execute("SELECT DISTINCT song_id from [#{genre}]")
			puts genre
			genre1 = genre.delete('/')
			FileUtils::mkdir_p "#{path}/#{genre1}"
			# puts songids
			Dir.chdir("#{path}/#{genre1}")
			songids.each do |songid|
				songs = db.execute("SELECT songtitle, artist, lyrics_ml, lyrics_w FROM master WHERE id = ? AND ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != ''))", songid['song_id'])
				puts songs.count
				if songs.count == 1
					then
					f = File.open("#{genre1}#{songid['song_id']}.txt", "w+")
					if songs[0]['lyrics_ml'] != nil && songs[0]['lyrics_ml'] != ''
						then
						lyrics = songs[0]['lyrics_ml']
						# .force_encoding('US-ASCII')
						# ('UTF-8', 'US-ASCII')
						f.write "#{lyrics}"
					elsif songs[0]['lyrics_w'] != nil && songs[0]['lyrics_w'] != ''
						lyrics = songs[0]['lyrics_w']
						# .force_encoding('US-ASCII')
						# ('UTF-8', 'US-ASCII')
						f.write "#{lyrics}"
					else
						puts "I only have blank lyrics for #{songs['songtitle']} by #{songs['artist']}."
					end
				else
					next
				end
			end
		end

	def self.write_albums(genres, dbname, root, path)

		db = SQLite3::Database.open(dbname)
		db.results_as_hash = true

		genres.each do |genre|
			Dir.chdir("#{root}")
			puts root
			songids = db.execute("SELECT DISTINCT master.id FROM master JOIN [#{genre}_albums] ON master.album_id = [#{genre}_albums].album_id")
			puts genre
			genre1 = genre.delete('/')
			FileUtils::mkdir_p "#{path}/#{genre1}"
			# puts songids
			Dir.chdir("#{path}/#{genre1}")
			songids.each do |songid|
				songs = db.execute("SELECT songtitle, artist, lyrics_ml, lyrics_w FROM master WHERE id = ? AND ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != ''))", songid['song_id'])
				puts songs.count
				if songs.count == 1
					then
					f = File.open("#{genre1}allalbums.txt", "a")
					if songs[0]['lyrics_ml'] != nil && songs[0]['lyrics_ml'] != ''
						then
						lyrics = songs[0]['lyrics_ml']
						# .force_encoding('US-ASCII')
						# ('UTF-8', 'US-ASCII')
						f.write "[NewSong]\n#{lyrics}"
					elsif songs[0]['lyrics_w'] != nil && songs[0]['lyrics_w'] != ''
						lyrics = songs[0]['lyrics_w']
						# .force_encoding('US-ASCII')
						# ('UTF-8', 'US-ASCII')
						f.write "[NewSong]\n#{lyrics}"
					else
						puts "I only have blank lyrics for #{songs['songtitle']} by #{songs['artist']}."
					end
				else
					next
				end
			end
		end
	end

	end
end
