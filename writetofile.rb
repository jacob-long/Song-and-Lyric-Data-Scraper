

require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'fileutils'

genres = ["rap", "R&B/hip hop", "country", "rock", "dance/electronic", "latin", "christian", "blues", "jazz", "new age", "reggae"]
# ["rap", "R&B/hip hop", "country", "rock", "dance/electronic", "pop", "latin", "christian"]
# years = ["2015", "2014"]

DBNAME = 'albumstest.sqlite'

DB = SQLite3::Database.new( DBNAME )
DB.results_as_hash = true

origdirectory = Dir.getwd

# genres.each do |genre|
# 	Dir.chdir("#{origdirectory}")
# 	songids = DB.execute("SELECT DISTINCT song_id from [#{genre}]")
# 	puts genre
# 	genre1 = genre.delete('/')
# 	FileUtils::mkdir_p "lyrics/#{genre1}"
# 	# puts songids
# 	Dir.chdir("lyrics/#{genre1}")
# 	songids.each do |songid|
# 		songs = DB.execute("SELECT songtitle, artist, lyrics_ml, lyrics_w FROM master WHERE id = ? AND ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != ''))", songid['song_id'])
# 		puts songs.count 
# 		if songs.count == 1
# 			then
# 			f = File.open("#{genre1}#{songid['song_id']}.txt", "w+")
# 			if songs[0]['lyrics_ml'] != nil && songs[0]['lyrics_ml'] != ''
# 				then
# 				lyrics = songs[0]['lyrics_ml']
# 				# .force_encoding('US-ASCII')
# 				# ('UTF-8', 'US-ASCII')
# 				f.write "#{lyrics}"
# 			elsif songs[0]['lyrics_w'] != nil && songs[0]['lyrics_w'] != ''
# 				lyrics = songs[0]['lyrics_w']
# 				# .force_encoding('US-ASCII')
# 				# ('UTF-8', 'US-ASCII')
# 				f.write "#{lyrics}"
# 			else
# 				puts "I only have blank lyrics for #{songs['songtitle']} by #{songs['artist']}."
# 			end
# 		else
# 			next
# 		end
# 	end  
# end

genres.each do |genre|
	Dir.chdir("#{origdirectory}")
	songids = DB.execute("SELECT DISTINCT song_id from [#{genre}_albums]")
	puts genre
	genre1 = genre.delete('/')
	FileUtils::mkdir_p "lyrics/#{genre1}"
	# puts songids
	Dir.chdir("lyrics/#{genre1}")
	songids.each do |songid|
		songs = DB.execute("SELECT songtitle, artist, lyrics_ml, lyrics_w FROM master WHERE id = ? AND ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != ''))", songid['song_id'])
		puts songs.count 
		if songs.count == 1
			then
			f = File.open("#{genre1}allalbums.txt", "a")
			if songs[0]['lyrics_ml'] != nil && songs[0]['lyrics_ml'] != ''
				then
				lyrics = songs[0]['lyrics_ml']
				# .force_encoding('US-ASCII')
				# ('UTF-8', 'US-ASCII')
				f.write "NewSong\n#{lyrics}"
			elsif songs[0]['lyrics_w'] != nil && songs[0]['lyrics_w'] != ''
				lyrics = songs[0]['lyrics_w']
				# .force_encoding('US-ASCII')
				# ('UTF-8', 'US-ASCII')
				f.write "NewSong\n#{lyrics}"
			else
				puts "I only have blank lyrics for #{songs['songtitle']} by #{songs['artist']}."
			end
		else
			next
		end
	end  
end



