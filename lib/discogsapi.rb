require 'rubygems'
require 'bundler/setup'

require 'discogs-wrapper'
require 'json'
require 'sqlite3'
require 'similar_text'

require_relative 'dbcalls'

module DiscogsAPI

	def self.get_tracklists(dbname)

		# included for crude benchmarking purposes
		beginning = Time.now

		# Authenticates with Discogs, "wrapper" variable will be used to initiate all interactions with the API
		#wrapper = Discogs::Wrapper.new("BB DB", app_key: "OgeBBIfpCfWxUuYujuSS", app_secret: "SaeoYeahnErQLhDUMMYHHgNIaLenfTaf")
		wrapper = Discogs::Wrapper.new("BB DB", user_token: "***REMOVED***")
		# target/source database (I'm assuming they are same, modifications could make working with two possible)
		db_name = "#{dbname}"

		db = SQLite3::Database.open( db_name )
		db.results_as_hash = true

		# Grabbing albums from database
		dbalbums = db.execute("SELECT * FROM album_master WHERE discogsrun IS NULL")
		# Creating a master songs table in case it does not already exist
		DBcalls::create_table_master

		# Performing searches on each album, one by one
		dbalbums.each do |album|
		
			# this cleanup improved search results
			album['albumtitle'].delete! '.'
			album['albumtitle'].delete! '!'
			album['albumtitle'].delete! '#'
			album['albumtitle'].delete! '+'
			album['albumtitle'].delete! ','
			album['albumtitle'].delete! '\''
			album['albumtitle'].gsub!(/\$/, 'S')
			album['albumtitle'].slice!(/.\(.*$/)
			album['albumtitle'].gsub!(/\&amp\;/, '&')
			album['albumtitle'].gsub!(/\&\#039\;/, '\'')
			album['albumtitle'].gsub!(/F\*\*k/, 'Fuck')
			album['albumtitle'].gsub!(/S\*\*t/, 'Shit')

			album['artist'].slice!(/.Featuring.*$/)
			album['artist'].slice!(/.With.*$/)
			album['artist'].slice!(/.\&amp\;.*$/)
			album['artist'].slice!(/,.*$/)
			album['artist'].slice!(/.\&.*$/)
			album['artist'].gsub!(/\$/, 'S')
			album['artist'].delete!('\'')
			album['artist'].gsub!(/"([^"]*)"./, '')

			# For ease of reading terminal output, can remove once confident it's working
			puts "#{album['artist']} - #{album['albumtitle']}"

			# Resetting here so each album gets 5 retries
			retries = 5

			# Trying to find balance between rate limit and performance
			sleep 1
		begin
			# Searching Discogs API
			result = wrapper.search("#{album['artist']} - #{album['albumtitle']}", :per_page => 10, :type => :release)

			# Hash needs to exist outside of upcoming block
			simscores = Hash.new

			# Calculating similarity scores for each search result with my search term because Discogs has mind-bogglingly bad search results
			result.results.each_with_index do |x, ind|
				res = x.title
				simscores[ind] = x.title.similar("#{album['artist']} - #{album['albumtitle']}")
			end

			# There's no need to delete the search results that aren't close, but by doing so I create a way to eliminate entirely albums that do not have any close matches
			simscores.delete_if{ |key, value| value < 75 }

			# This prevents albums with no close matches from having the wrong data inserted into database
			if simscores == {}
				then
				puts "No solid match found."
				next
			else
				choice = simscores.max_by { |k, v| v }[0]
				# puts "Chose: \"#{result.results[choice].title}\", which was result number #{choice+1}"
			end

			# Adding this metadata to database for future use. Catalog number is a standard that stretches beyond Discogs
			discogsid = result.results[choice].id
			catnum = result.results[choice].catno

			foundalbum = wrapper.get_release("#{discogsid}")
			db.execute("UPDATE album_master SET discogsid = ? WHERE id = ?", discogsid, album['id'])
			db.execute("UPDATE album_master SET catnum = ? WHERE id = ?", catnum, album['id'])
			db.execute("UPDATE album_master SET discogsrun = 'TRUE' where id = ?", album['id'])

			# Iterating through each song on the tracklist and adding them to the songs table
			foundalbum.tracklist.each do |x|
				begin
					# Using the extra artists category for dealing with "various artists" albums
					extras = []
					if x.extraartists != nil
						then x.extraartists.each{ |y| extras.push(y.name) }
					else extras = nil
					end
				
					# Putting all the information into the table now
					if x.title != '' && x.title != nil
						DB.execute("INSERT INTO master (songtitle, artist, album_title, album_id, num_on_album, from_album_chart, extra_artists) VALUES (?,?,?,?,?,?,?)",
						"#{x.title}", "#{album['artist']}", "#{foundalbum.title}", "#{album['id']}", "#{x.position}", "true", "#{extras}")
					else
						next
					end

				# No need to worry about the DB rejecting duplicate entries
				rescue SQLite3::ConstraintException
					next
				end
		end
	
		# Shouldn't be getting this, but you never know
		rescue NoMethodError => e
			puts e.message
			puts e.backtrace.inspect
			next
	
		# Discogs seems to have some very informal rate limiting mechanism, resulting in a few different sorts of errors.
		rescue Errno::ECONNRESET => e
			puts "\tError: #{e}"
			if retries > 0
				retries -= 1
				puts "\tConnection error. #{retries} retries remaining..."
				sleep 10
				retry
			else
				puts "Couldn't connect after 5 tries. Moving on..."
				next
			end
		rescue OpenSSL::SSL::SSLError => e
			puts "\tError: #{e}"
			if retries > 0
				retries -= 1
				puts "\tConnection error. #{retries} retries remaining..."
				sleep 2
				retry
			else
				puts "Couldn't connect after 5 tries. Moving on..."
				next
			end
		end
end

		puts
		puts "Time elapsed using Discogs: #{Time.now - beginning} seconds."

	end

end