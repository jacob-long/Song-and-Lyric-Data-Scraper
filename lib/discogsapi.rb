require 'rubygems'
require 'bundler/setup'

require 'discogs-wrapper'
require 'json'
require 'sqlite3'
require 'similar_text'
require 'ruby-progressbar'

require_relative 'dbcalls'

module DiscogsAPI

	def self.get_tracklists(dbname, token)

		# Authenticates with Discogs, "wrapper" variable will be used to initiate all interactions with the API
		wrapper = Discogs::Wrapper.new("BB DB", user_token: token)
		# target/source database (I'm assuming they are same, modifications could make working with two possible)
		db_name = "#{dbname}"

		db = SQLite3::Database.open( db_name )
		db.results_as_hash = true

		# Grabbing albums from database
		dbalbums = db.execute("SELECT * FROM album_master WHERE discogsid IS NULL AND
		 (spotifyid IS NULL OR spotify_run IS NULL) AND 
		 (from_single != 'TRUE' OR from_single IS NULL) AND discogsrun IS NULL ")
		# Creating a master songs table in case it does not already exist
		DBcalls::create_table_master

		num_albums = dbalbums.length
		prog_bar = ProgressBar.create(:title => "Discogs album tracklists progress",
									   :starting_at => 0,
									    :total => num_albums)

		# Performing searches on each album, one by one
		dbalbums.each do |album|
		
			album['albumtitle'] = alb_title_clean(album['albumtitle'])
			album['artist'] = artist_clean(album['artist'])

			# Resetting here so each album gets 5 retries
			retries = 5

			# Trying to find balance between rate limit and performance
			sleep 0.5
		begin
			# Searching Discogs API
			result = wrapper.search("#{album['artist']} - #{album['albumtitle']}",
									 per_page: "10",
									 type: "release")

			# Hash needs to exist outside of upcoming block
			simscores = Hash.new

			# Calculating similarity scores for each search result with my search term because Discogs has mind-bogglingly bad search results
			if result != nil 
				result.results.each_with_index do |x, ind|
					res = x.title
					simscores[ind] = x.title.similar("#{album['artist']} - #{album['albumtitle']}")
				end
			else 
				db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])
				prog_bar.increment
				next
			end

			# There's no need to delete the search results that aren't close, but by doing so I create a way to eliminate entirely albums that do not have any close matches
			simscores.delete_if{ |key, value| value < 75 }

			# This prevents albums with no close matches from having the wrong data inserted into database
			if simscores == {}
				then
				prog_bar.increment
				db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])
				next
			else
				choice = simscores.max_by { |k, v| v }[0]
			end

			# Adding this metadata to database for future use. Catalog number is a standard that stretches beyond Discogs
			discogsid = result.results[choice].id
			catnum = result.results[choice].catno
		
			foundalbum = wrapper.get_release_lim("#{discogsid}")
			db.execute("UPDATE album_master SET discogsid = ? WHERE id = ?", discogsid, album['id'])
			db.execute("UPDATE album_master SET catnum = ? WHERE id = ?", catnum, album['id'])
			db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])

			# Iterating through each song on the tracklist and adding them to the songs table
			foundalbum.tracklist.each do |x|
				begin
					# Using the extra artists category for dealing with "various artists" albums
					extras = []
					if x["extraartists"] != nil
						then x["extraartists"].each{ |y| extras.push(y.name) }
					else extras = nil
					end

					# This is to identify tracks that came from albums that did not themselves make a chart
					if album['from_single'] == 'TRUE'
						# For now, don't want any of these.
						# DB.execute("INSERT INTO master (songtitle, artist, album_title, album_id, num_on_album, 
						# from_album_song, extra_artists) VALUES (?,?,?,?,?,?,?)",
						# 					 "#{x.title}", "#{album['artist']}",
						#  "#{foundalbum.title}", "#{album['id']}", "#{x.position}", "true", "#{extras}")
						db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])
						prog_bar.increment
					else
					# Putting all the information into the table now
						if x.title != '' && x.title != nil
							DB.execute("INSERT INTO master 
								(songtitle, artist, album_title, album_id, num_on_album,
								 from_album_chart, extra_artists)
								VALUES (?,?,?,?,?,?,?)",
								"#{x.title}", "#{album['artist']}", "#{foundalbum.title}",
								"#{album['id']}", "#{x.position}", "true", "#{extras}")
						else
							next
						end
					end
					
				# No need to worry about the DB rejecting duplicate entries
				rescue SQLite3::ConstraintException
					db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])
					next
				end
			
			end

			prog_bar.increment
	
		# Shouldn't be getting this, but you never know
		rescue NoMethodError => e
			prog_bar.log e.message
			prog_bar.log e.backtrace.inspect
			next
	
		# Discogs seems to have some very informal rate limiting mechanism, resulting in a few different sorts of errors.
		rescue Errno::ECONNRESET => e
			prog_bar.log "\tError: #{e}"
			if retries > 0
				retries -= 1
				prog_bar.log "\tConnection error. #{retries} retries remaining..."
				sleep 10
				retry
			else
				prog_bar.log "Couldn't connect after 5 tries. Moving on..."
				db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])
				next
			end
		rescue OpenSSL::SSL::SSLError => e
			prog_bar.log "\tError: #{e}"
			if retries > 0
				retries -= 1
				prog_bar.log "\tConnection error. #{retries} retries remaining..."
				sleep 2
				retry
			else
				prog_bar.log "Couldn't connect after 5 tries. Moving on..."
				db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])
				next
			end
		end
	end
	end

end

# These changes, in addition to the fixes in my fork of discogs-wrapper,
# stop the warnings from Hashie from key clashes
class Discogs::Wrapper 

	def get_release_lim(release_id)
		query_and_build_lim "releases/#{release_id}"
	end

	def query_and_build_lim(path, params={}, method=:get, body=nil)
		parameters = {:f => "json"}.merge(params)
		data = query_api(path, params, method, body)

		if data != ""
		hash = JSON.parse(data)
		hash = hash.select {|key, value| ["id", "tracklist", "title"].include?(key) }
		if hash["tracklist"].is_a?(Array)
		  hash["tracklist"].each_index do |x|
			hash["tracklist"][x] = sanitize_hash(hash["tracklist"][x])
		  end
		end
		Hashie::Mash.new(sanitize_hash(hash))
		else
		Hashie::Mash.new
		end
	end

end

# These methods edit the album titles and artist names to increase search success
# with Discogs
class String
	def DiscogsAPI.alb_title_clean(x)
		# this cleanup improved search results
		x.delete! '.'
		x.delete! '!'
		x.delete! '#'
		x.delete! '+'
		x.delete! ','
		x.delete! '\''
		x.gsub!(/\$/, 'S')
		x.slice!(/.\(.*$/)
		x.gsub!(/\&amp\;/, '&')
		x.gsub!(/\&\#039\;/, '\'')
		x.gsub!(/F\*\*k/, 'Fuck')
		x.gsub!(/S\*\*t/, 'Shit')
		x
	end
	
	def DiscogsAPI.artist_clean(x)
		x.slice!(/.Featuring.*$/)
		x.slice!(/.With.*$/)
		x.slice!(/.\&amp\;.*$/)
		x.slice!(/,.*$/)
		x.slice!(/.\&.*$/)
		x.gsub!(/\$/, 'S')
		x.delete!('\'')
		x.gsub!(/"([^"]*)"./, '')
		x.gsub!(/Various Artists/, 'Various')
		x
	end
end