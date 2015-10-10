require 'rubygems'
require 'bundler/setup'

require 'Simple-RSS'
require 'Lyricfy'
require 'nokogiri'
require 'yaml'
require 'RSpotify'
require 'json'
require 'sqlite3'

module Lyricsearch

	def self.primary_lyric_search(dbname)

		db = SQLite3::Database.open "#{dbname}"
		db.results_as_hash = true

		# Wikia search–only includes titles that do not already have lyrics from W listed.
		db.execute("SELECT id, songtitle, artist FROM master WHERE (lyrics_w IS NULL OR lyrics_w = '') AND id >2140") do |row|

			row['songtitle'].gsub!(/\&amp\;/, '&')
			row['songtitle'].gsub!(/\&\#039\;/, '\'')
			row['songtitle'].gsub!(/F\*\*k/, 'Fuck')
			row['songtitle'].gsub!(/S\*\*t/, 'Shit')

			row['artist'].slice!(/.Featuring.*$/)
			row['artist'].slice!(/.With.*$/)
			row['artist'].gsub!(/\&amp\;/, '&')
			row['artist'].gsub!(/\&\#039\;/, '\'')
			row['artist'].gsub!(/"([^"]*)"./, '')

			begin
				fetcher = Lyricfy::Fetcher.new(:wikia)
				song = fetcher.search "#{row['artist']}", "#{row['songtitle']}"
				# Trying to deal with false positives resulting from a body of 0 characters being saved as lyrics
				if song.body == ''
					puts "Found empty body of lyrics. Skipping..."
					next
				else
					songw = song.body("\n")
					db.execute("UPDATE master SET lyrics_w = ? WHERE id = #{row['id']}", "#{songw}")
					puts "Used Wikia successfully (id: #{row['id']})"
				end
			rescue
				puts "Can't find #{row['songtitle']} by #{row['artist']} (id: #{row['id']}) with Wikia."
				next
			end
		end

		# MetroLyrics search–only includes titles that do not already have lyrics from ML listed.
		db.execute("SELECT id, songtitle, artist FROM master WHERE (lyrics_ml IS NULL OR lyrics_ml = '')") do |row|

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

			begin
				fetcher2 = Lyricfy::Fetcher.new(:metro_lyrics)
				song2 = fetcher2.search "#{row['artist']}", "#{row['songtitle']}"
				# Trying to deal with false positives resulting from a body of 0 characters being saved as lyrics
				if song2.body == ''
					puts "Found empty body of lyrics. Skipping..."
					raise StandardError
				else
					songml = song2.body("\n")
					db.execute("UPDATE master SET lyrics_ml = ? WHERE id = #{row['id']}", "#{songml}")
					puts "Used MetroLyrics successfully. (id: #{row['id']})"
				end
			rescue
				puts "I couldn't find lyrics for #{row['songtitle']} by #{row['artist']} (id: #{row['id']}) on MetroLyrics."
				next
			end
		end

		# Below I'm just calculating some rough numbers on how successful the lyric search was and outputting to console
		stmt = db.execute( "select * from master" )
		stmt = stmt.length
		puts "Total songs: #{stmt}"

		stmt2 = db.execute( "select * from master WHERE (lyrics_w NOTNULL AND lyrics_w <> '') OR (lyrics_ml NOTNULL AND lyrics_ml <> '') AND id > 62000" )
		stmt2 = stmt2.length
		totalfails = (stmt - stmt2)

		metrolyricsrate = metrosuccess.count{ |i| i == true }
		wikiarate = wikiasuccess.count{ |i| i == true }

		puts "Metrolyrics found #{metrolyricsrate} tracks out of #{stmt}."
		puts "Wikia found #{wikiarate} tracks out of #{stmt}."
		puts "I couldn't find lyrics for #{totalfails} tracks out of #{stmt} total."
	end

	def self.metro_alt_search(dbname)
		db = SQLite3::Database.open "#{dbname}"
		db.results_as_hash = true

		ml_have = db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE lyrics_ml IS NULL OR lyrics_ml = ''")
		ml_have = ml_have.count

		song_total = db.execute("SELECT * FROM master")
		song_total = song_total.count

		puts "Before this search, I have #{song_total - ml_have} songs without lyrics from MetroLyrics."

		db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE lyrics_ml IS NULL OR lyrics_ml = ''") do |row|

			if row['alt_songtitle'] != nil then
			row['alt_songtitle'].delete! '.'
			row['alt_songtitle'].delete! '!'
			row['alt_songtitle'].delete! '#'
			row['alt_songtitle'].delete! '+'
			row['alt_songtitle'].delete! ','
			row['alt_songtitle'].delete! '\''
			row['alt_songtitle'].slice!(/.\(.*$/)
			row['alt_songtitle'].gsub!(/\&amp\;/, '&')
			row['alt_songtitle'].gsub!(/\&\#039\;/, '\'')
			row['alt_songtitle'].gsub!(/F\*\*k/, 'Fuck')
			row['alt_songtitle'].gsub!(/S\*\*t/, 'Shit')
			row['alt_songtitle'].gsub!(/.\(feat.*/, '')
			row['alt_songtitle'].gsub!(/.- feat.*/, '')

			begin
				fetcher2 = Lyricfy::Fetcher.new(:metro_lyrics)
				song2 = fetcher2.search "#{row['artist']}", "#{row['alt_songtitle']}"
				# puts song2.body
				songml = song2.body("\n")
				db.execute("UPDATE master SET lyrics_ml = ? WHERE id = #{row['id']}", "#{songml}")
				metrosuccess.push(true)
			rescue
				puts "I couldn't find lyrics for #{row['songtitle']} by #{row['artist']} on MetroLyrics with alternate songtitle."
				next
			end

			elsif row['alt_artist'] != nil then
			row['alt_artist'].slice!(/.Featuring.*$/)
			row['alt_artist'].slice!(/.With.*$/)
			row['alt_artist'].slice!(/.\&amp\;.*$/)
			row['alt_artist'].slice!(/,.*$/)
			row['alt_artist'].slice!(/.\&.*$/)
			row['alt_artist'].gsub!(/\$/, 'S')
			row['alt_artist'].delete!('-')
			row['alt_artist'].delete!('\'')
			row['alt_artist'].gsub!(/"([^"]*)"./, '')

			begin
				fetcher2 = Lyricfy::Fetcher.new(:metro_lyrics)
				song2 = fetcher2.search "#{row['alt_artist']}", "#{row['songtitle']}"
				# puts song2.body
				songml = song2.body("\n")
				db.execute("UPDATE master SET lyrics_ml = ? WHERE id = #{row['id']}", "#{songml}")
			rescue
				puts "I couldn't find lyrics for #{row['songtitle']} by #{row['artist']} on MetroLyrics with alternate songtitle."
				next
			end

			else puts "I don't have alternate metadata for #{row['songtitle']} by #{row['artist']}"
				next
			end

		end

		ml_have_2 = db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE lyrics_ml IS NULL OR lyrics_ml = ''")
		ml_have_2 = ml_have_2.count

		puts "After secondary search, I have #{song_total - ml_have_2} songs without lyrics from MetroLyrics. That's #{ml_have_2 - ml_have} additional songs!"

	end

	def self.wikia_alt_search(dbname)
		db = SQLite3::Database.open "#{dbname}"
		db.results_as_hash = true

		w_have = db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE lyrics_w IS NULL OR lyrics_w = '' AND id > 62000")
		w_have = w_have.count

		song_total = db.execute("SELECT * FROM master")
		song_total = song_total.count

		puts "Before this search, I have #{song_total - w_have} songs with lyrics from Wikia."

		db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE lyrics_w IS NULL OR lyrics_w = ''") do |row|

			if row['alt_songtitle'] != nil then
				row['alt_songtitle'].gsub!(/\&amp\;/, '&')
				row['alt_songtitle'].gsub!(/\&\#039\;/, '\'')
				row['alt_songtitle'].gsub!(/F\*\*k/, 'Fuck')
				row['alt_songtitle'].gsub!(/S\*\*t/, 'Shit')
				row['alt_songtitle'].gsub!(/.\(feat.*/, '')
				row['alt_songtitle'].gsub!(/.- feat.*/, '')

			begin
				fetcher2 = Lyricfy::Fetcher.new(:wikia)
				song2 = fetcher2.search "#{row['artist']}", "#{row['alt_songtitle']}"
				# puts song2.body
				songml = song2.body("\n")
				db.execute("UPDATE master SET lyrics_w = ? WHERE id = #{row['id']}", "#{songml}")
				metrosuccess.push(true)
			rescue
				puts "I couldn't find lyrics for #{row['songtitle']} by #{row['artist']} on Wikia with alternate songtitle."
				next
			end

			elsif row['alt_artist'] != nil then
				row['alt_artist'].slice!(/.Featuring.*$/)
				row['alt_artist'].slice!(/.With.*$/)
				row['alt_artist'].slice!(/.\&.*$/)
				row['alt_artist'].gsub!(/"([^"]*)"./, '')

			begin
				fetcher2 = Lyricfy::Fetcher.new(:wikia)
				song2 = fetcher2.search "#{row['alt_artist']}", "#{row['songtitle']}"
				# puts song2.body
				songml = song2.body("\n")
				db.execute("UPDATE master SET lyrics_w = ? WHERE id = #{row['id']}", "#{songml}")
			rescue
				puts "I couldn't find lyrics for #{row['songtitle']} by #{row['artist']} on Wikia with alternate songtitle."
				next
			end

			else puts "I don't have alternate metadata for #{row['songtitle']} by #{row['artist']}"
				next
			end

		end

		w_have_2 = db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE lyrics_w IS NULL OR lyrics_w = ''")
		w_have_2 = w_have_2.count

		puts "After secondary search, I have #{song_total - w_have_2} songs with lyrics from Wikia. That's #{w_have_2 - w_have} additional songs!"

	end

end