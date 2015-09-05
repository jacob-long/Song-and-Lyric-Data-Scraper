require 'rubygems'
require 'bundler/setup'

require 'Simple-RSS'
require 'Lyricfy'
require 'nokogiri'
require 'yaml'
require 'RSpotify'
require 'json'
require 'sqlite3'

require_relative 'songclass'
module Lyricsearch

	def metro_alt_search(dbname)
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
				metrosuccess.push(true)
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

	def wikia_alt_search(dbname)
		db = SQLite3::Database.open "#{dbname}"
		db.results_as_hash = true

		w_have = db.execute("SELECT id, songtitle, alt_songtitle, artist, alt_artist FROM master WHERE lyrics_w IS NULL OR lyrics_w = ''")
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
				metrosuccess.push(true)
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

		puts "After secondary search, I have #{song_total - w_have_2} songs with lyrics from MetroLyrics. That's #{w_have_2 - w_have} additional songs!"

	end

end