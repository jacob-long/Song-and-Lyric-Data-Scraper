require 'rubygems'
require 'bundler/setup'

require 'Echowrap'
require 'sqlite3'
require 'nokogiri'
require 'open-uri'
require 'json'
# require 'crack'

DBNAME = "finaldata.sqlite"
DB = SQLite3::Database.open( DBNAME )

# Echo Nest API keys and such, don't share with public
Echowrap.configure do |config|
  config.api_key =       'UQHQ5ON6UJ3FXV4UB'
  config.consumer_key =  'b4a21f70d81680d02d4f8390225d1986'
  config.shared_secret = 'iebmiY4TRIaiUI08HjpqdQ'
end

# trackid = []
# tracktempo = []
# analysis_url = []
# analysis_parse = []
# jsonobject = []

number_selected = []
number_rescued = []

# The following loops through each row in the database, then passing it to Echo Nest API, 
# which writes its various outputs to the specified columns in the database

DB.results_as_hash = true
DB.execute(" SELECT id, artist, songtitle FROM master WHERE echonest_id IS NULL AND id > 3367") do |x|
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
		sleep(0.5)
	puts
	puts x['id']
	Echowrap.song_search(:artist => x['artist'], :title => x['songtitle'], :bucket => ['audio_summary', 'artist_location'], :results => 1).map do |song|
		number_selected.push("1")
		# puts song.inspect
		# puts song.audio_summary.instrumentalness
		# puts x['id']
		begin
			puts "Found it!"
			# The convoluted syntax is necessary because I'm updating an existing data table. 
			DB.execute_batch("
				UPDATE master SET echonest_id ='#{song.id.to_s}' WHERE id='#{x['id']}'; 
				UPDATE master SET key ='#{song.audio_summary.key}' WHERE id='#{x['id']}';
				UPDATE master SET energy ='#{song.audio_summary.energy}' WHERE id='#{x['id']}';
				UPDATE master SET liveness ='#{song.audio_summary.liveness}' WHERE id='#{x['id']}';
				UPDATE master SET loudness ='#{song.audio_summary.loudness}' WHERE id='#{x['id']}';
				UPDATE master SET valence ='#{song.audio_summary.valence}' WHERE id='#{x['id']}';
				UPDATE master SET danceability ='#{song.audio_summary.danceability}' WHERE id='#{x['id']}';
				UPDATE master SET tempo ='#{song.audio_summary.tempo}' WHERE id='#{x['id']}';
				UPDATE master SET speechiness ='#{song.audio_summary.speechiness}' WHERE id='#{x['id']}';
				UPDATE master SET acousticness ='#{song.audio_summary.acousticness}' WHERE id='#{x['id']}';
				UPDATE master SET mode ='#{song.audio_summary.mode}' WHERE id='#{x['id']}';
				UPDATE master SET time_signature ='#{song.audio_summary.time_signature}' WHERE id='#{x['id']}';
				UPDATE master SET duration ='#{song.audio_summary.duration}' WHERE id='#{x['id']}';
				UPDATE master SET analysis_url ='#{song.audio_summary.analysis_url}' WHERE id='#{x['id']}';
				UPDATE master SET instrumentalness ='#{song.audio_summary.instrumentalness}' WHERE id='#{x['id']}';
				UPDATE master SET artist_location ='#{song.artist_location.location}' WHERE id='#{x['id']}';
			")

			# This grabs the detailed analysis from the link embedded in the search result
			analysis_url = song.audio_summary.analysis_url
			# sleep(3) - not needed because my API rate limit was lifted
			jsonobject = open(analysis_url)
			analysis_parse = JSON.parse(jsonobject.first)
			
			# This adds additional data from the JSON analysis document.
			DB.execute_batch("
				UPDATE master SET key_confidence ='#{analysis_parse['track']['key_confidence']}' WHERE id='#{x['id']}';
				UPDATE master SET audio_md5 ='#{analysis_parse['track']['audio_md5']}' WHERE id='#{x['id']}';
				UPDATE master SET tempo_confidence ='#{analysis_parse['track']['tempo_confidence']}' WHERE id='#{x['id']}';
				UPDATE master SET mode_confidence ='#{analysis_parse['track']['mode_confidence']}' WHERE id='#{x['id']}';
				UPDATE master SET time_signature_confidence ='#{analysis_parse['track']['time_signature_confidence']}' WHERE id='#{x['id']}';
			")
		rescue Exception => e  
		puts e.message  
  		puts e.backtrace.inspect  
		puts "Problem with #{x['songtitle']} by #{x['artist']}. Moving on..."
		number_rescued.push("1")
		next
		end
	end
	# Echowrap.artist_search(:name => x['artist'] :results => 1)
end

# DB.execute(" SELECT id, artist, songtitle, spotifyid FROM master WHERE echonest_id IS NULL AND spotifyid !='None' ") do |x|
# 	sleep(0.5)
# 	spotid = "spotify:track:#{x['spotifyid']}"
# 	begin
# 	Echowrap.song_profile(:id => spotid, :bucket => ['audio_summary', 'artist_location'], :results => 1).map do |song|
# 		number_selected.push("1")
# 		# puts song.inspect
# 		# puts song.audio_summary.instrumentalness
# 		# puts x['id']
# 		begin
# 			puts song.inspect
# 			# The convoluted syntax is necessary because I'm updating an existing data table. 
# 			DB.execute_batch("
# 				UPDATE master SET echonest_id ='#{song.id.to_s}' WHERE id='#{x['id']}'; 
# 				UPDATE master SET key ='#{song.audio_summary.key}' WHERE id='#{x['id']}';
# 				UPDATE master SET energy ='#{song.audio_summary.energy}' WHERE id='#{x['id']}';
# 				UPDATE master SET liveness ='#{song.audio_summary.liveness}' WHERE id='#{x['id']}';
# 				UPDATE master SET loudness ='#{song.audio_summary.loudness}' WHERE id='#{x['id']}';
# 				UPDATE master SET valence ='#{song.audio_summary.valence}' WHERE id='#{x['id']}';
# 				UPDATE master SET danceability ='#{song.audio_summary.danceability}' WHERE id='#{x['id']}';
# 				UPDATE master SET tempo ='#{song.audio_summary.tempo}' WHERE id='#{x['id']}';
# 				UPDATE master SET speechiness ='#{song.audio_summary.speechiness}' WHERE id='#{x['id']}';
# 				UPDATE master SET acousticness ='#{song.audio_summary.acousticness}' WHERE id='#{x['id']}';
# 				UPDATE master SET mode ='#{song.audio_summary.mode}' WHERE id='#{x['id']}';
# 				UPDATE master SET time_signature ='#{song.audio_summary.time_signature}' WHERE id='#{x['id']}';
# 				UPDATE master SET duration ='#{song.audio_summary.duration}' WHERE id='#{x['id']}';
# 				UPDATE master SET analysis_url ='#{song.audio_summary.analysis_url}' WHERE id='#{x['id']}';
# 				UPDATE master SET instrumentalness ='#{song.audio_summary.instrumentalness}' WHERE id='#{x['id']}';
# 				UPDATE master SET artist_location ='#{song.artist_location.location}' WHERE id='#{x['id']}';
# 			")

# 			# This grabs the detailed analysis from the link embedded in the search result
# 			analysis_url = song.audio_summary.analysis_url
# 			# sleep(3) - not needed because my API rate limit was lifted
# 			jsonobject = open(analysis_url)
# 			analysis_parse = JSON.parse(jsonobject.first)
			
# 			# This adds additional data from the JSON analysis document.
# 			DB.execute_batch("
# 				UPDATE master SET key_confidence ='#{analysis_parse['track']['key_confidence']}' WHERE id='#{x['id']}';
# 				UPDATE master SET audio_md5 ='#{analysis_parse['track']['audio_md5']}' WHERE id='#{x['id']}';
# 				UPDATE master SET tempo_confidence ='#{analysis_parse['track']['tempo_confidence']}' WHERE id='#{x['id']}';
# 				UPDATE master SET mode_confidence ='#{analysis_parse['track']['mode_confidence']}' WHERE id='#{x['id']}';
# 				UPDATE master SET time_signature_confidence ='#{analysis_parse['track']['time_signature_confidence']}' WHERE id='#{x['id']}';
# 			")
# 		rescue Exception => e  
# 			puts e.message  
#   			puts e.backtrace.inspect  
# 			puts "Problem with #{x['songtitle']} by #{x['artist']}. Moving on..."
# 			number_rescued.push("1")
# 			next
# 		end
# 	end 
# 	rescue StandardError => e
# 		puts e
# 		next
# 	end
# end

puts number_selected.length
puts number_rescued.length
# puts trackid
# puts tracktempo
# puts analysis_parse["track"]

# Looks like this is bad code. Saving just in case.
# insert_song = "UPDATE testdata(
# # 	echonest_id, 
# # 	key, 
# # 	key_confidence, 
# # 	energy, 
# # 	liveness, 
# # 	loudness, 
# # 	audio_md5, 
# # 	valence, 
# # 	danceability, 
# # 	tempo, 
# # 	tempo_confidence, 
# # 	speechiness, 
# # 	acousticness, 
# # 	instrumentalness, 
# # 	mode, 
# # 	mode_confidence, 
# # 	time_signature, 
# # 	time_signature_confidence, 
# # 	duration, 
# # 	analysis_url
# # 	) 
# # VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
