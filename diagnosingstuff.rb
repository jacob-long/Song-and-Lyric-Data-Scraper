require 'rubygems'
# require 'bundler/setup'

require 'sqlite3'

DBNAME = 'albumstest.sqlite'

DB = SQLite3::Database.new( DBNAME )
DB.results_as_hash = true

genres = ["rap", "R&B/hip hop", "country", "rock", "dance/electronic", "latin", "christian", "blues", "jazz", "new age", "reggae"]

albsondiscogs = DB.execute("SELECT DISTINCT album_id FROM master")
albstotal = DB.execute("SELECT DISTINCT id from album_master")

puts "Have tracklists from #{albsondiscogs.count} of #{albstotal.count}."

lyricsfound = DB.execute("SELECT songtitle, artist, lyrics_ml, lyrics_w FROM master WHERE ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != ''))")
songsfound = DB.execute("SELECT DISTINCT * FROM master")

puts "Have lyrics for #{lyricsfound.count} of the #{songsfound.count} tracks found on Discogs."

genres.each do |genre|
	
	# genretable = "#{genre}_albums"
	albstotal = DB.execute(" SELECT DISTINCT album_id FROM [#{genre}_albums]" )
	albsondiscogs = DB.execute("SELECT DISTINCT album_id FROM master WHERE album_id IN (SELECT album_id FROM [#{genre}_albums])")

	puts "Have tracklists from #{albsondiscogs.count} of #{albstotal.count} for #{genre}."

	lyricsfound = DB.execute("SELECT lyrics_ml, lyrics_w FROM master WHERE ((lyrics_w NOTNULL AND lyrics_w != '') OR (lyrics_ml NOTNULL AND lyrics_ml != '')) AND album_id IN (SELECT album_id FROM [#{genre}_albums])")
	songsfound = DB.execute("SELECT DISTINCT * FROM master WHERE album_id IN (SELECT album_id FROM [#{genre}_albums])")

	puts "Have lyrics for #{lyricsfound.count} of the #{songsfound.count} tracks found on Discogs for #{genre}."

end