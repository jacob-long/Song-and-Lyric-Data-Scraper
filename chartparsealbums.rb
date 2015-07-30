require 'rubygems'
require 'bundler/setup'

require 'json'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'date'

require_relative 'linkclass'
require_relative 'dbcalls'

genres = ["R&B/hip hop"]
# ["rap", "R&B/hip hop", "country", "rock", "dance/electronic", "latin", "christian", "blues", "jazz", "new age", "reggae"]
years = ["2010", "2011", "2012", "2013", "2014", "2015"]

link = Link.new

DBNAME = "albumstest.sqlite"
# File.delete(DBNAME) if File.exists?DBNAME

DB = SQLite3::Database.new( DBNAME )

DBcalls::create_album_master
DBcalls::create_table_master
DB.results_as_hash = true

# Iterating through each genre
genres.each do |genres|
	link.genre = genres
	puts link.genre

	DBcalls::create_album_genre(link.genre)
	
	# Iterating through each year
	years.each do |years|
		link.year = years.to_i
		puts link.year
		
		# Iterating through each week
		for w in 1...53 do
			begin
				puts
				link.week = w
				link.date_get
				linkdate = link.date_get
				link.url_albums
				linkurl = link.url_make
				# puts linkurl

				# Dealing with future dates
				if linkdate > Date.today+6 == true
					then next
				else
				puts linkdate
				end

			# This rescue is for dealing with the every few years that there is a 53rd Saturday.
			rescue
				puts "#{linkdate} is not a valid date! Moving to the next year..."
				if linkdate.valid_date? == true
					then next
				end
			end
			retries = 3
			begin 

			# Grabbing the chart page from billboard.com	
			page2 = Nokogiri::HTML(open(linkurl, 'User-Agent' => 'ruby'))

			# Fetching songtitles
			titlespre = page2.css('main#main.page-content div.chart-data div.container article.chart-row div.row-primary div.row-title h2')

			# Grooming and storing songtitle entries.
			titles = []
			titlespre.each do |x|
				titles.push(x.text.to_s)
			end

			titles.each do |x|
				x.lstrip!
				x.rstrip!
				x.gsub!(/\'/, '\'\'')
			end

			# Fetching artists
			artistspre = page2.css('main#main.page-content div.chart-data div.container article.chart-row div.row-primary div.row-title h3')

			# Grooming and storing artist entries.
			artists = []
			artistspre.each do |x|
				artists.push(x.text.to_s)
			end

			artists.each do |x|
				x.lstrip!
				x.rstrip!
				x.gsub!(/\'/, '\'\'')
			end

			# Making sure there are no errors parsing song titles and artist names.
			if titles.count == artists.count
				upperbound = titles.count
			else 
				puts "Number of titles and artists don't match!"
			end

			# Retrieving, grooming, and storing each song's Spotify ID (if one exists).
			spotifyids = []
			for q in 1...upperbound+1 do
				begin
					pageparse3 = page2.css("main#main.page-content div.chart-data div.container article#row-#{q}.chart-row div.row-primary a.spotify")
					spotifyids.push(pageparse3[0]['href'])
				rescue
					# puts "No Spotify entry found."
					spotifyids.push("None")
					next
				end
			end

			spotifyids.each do |x|
				x.gsub!(/https:\/\/embed.spotify.com\/\?uri=spotify\:album\:/, '')
			end

			# Retrieving, grooming, and storing each song's rank on that week's list.
			ranks = []
			rankspre = page2.css('main#main.page-content div.chart-data div.container article.chart-row div.row-primary div.row-rank span.this-week')
			rankspre.each do |x|
				ranks.push(x.text)
			end

			# Retrieving, grooming, and storing each song's rank on that week's list.
			ranks_last = []
			ranks_last_pre = page2.css('main#main.page-content div.chart-data div.container article.chart-row div.row-primary div.row-rank span.last-week')
			ranks_last_pre.each do |x|
				ranks_last.push(x.text)
			end

			ranks_last.each do |x|
				x.gsub!(/Last Week\:/, '')
				x.lstrip!
				x.rstrip!
			end

			# Error handling for problems with opening webpages.
			rescue StandardError=>e
			   puts "\tError: #{e}"
				if retries > 0
			       puts "\tCan't access the webpage for #{link.genre} on #{linkdate}. Going to try again #{retries} more times"
			       retries -= 1
			       sleep 1
			       retry
				else
			       puts "\t\tCouldn't access on further attempts, either. Try visiting #{linkurl}"
			       next
				end
			end

			# Inserts songs into master table that contains all songs
			for i in 0...upperbound do
				begin
				DB.execute("INSERT INTO album_master(albumtitle, artist, spotifyid) VALUES ('#{titles[i]}', '#{artists[i]}', '#{spotifyids[i]}')")
				rescue SQLite3::ConstraintException
					next
				rescue StandardError => e
					puts "Error: Check if number of titles and artists match for the #{link.genre} genre on #{linkdate}."
					puts e
				end			
			end

			# Inserts songs into genre-named table. 
			for i in 0...upperbound do
				begin
					DB.execute("INSERT INTO [#{link.genre}_albums](albumtitle, artist, genre_bb, date, year, week, rank, rank_last) 
						VALUES ('#{titles[i]}', '#{artists[i]}', '#{link.genre_snip}', '#{linkdate}', 
						'#{years}', '#{w}', '#{ranks[i]}', '#{ranks_last[i]}') ")
				rescue SQLite3::ConstraintException
					next
				rescue StandardError=>e
					puts "Error: Check if number of titles and artists match for the #{link.genre} genre on #{linkdate}."
					puts e 
				end
				begin
					# prevents lookup errors due to apostrophe
					titles[i].gsub!(/\'\'/, '\'')
					artists[i].gsub!(/\'\'/, '\'')

					# grabbing album ID from master table
					preidstmt = DB.prepare("SELECT id FROM album_master WHERE albumtitle LIKE ? AND artist LIKE ?")
					preid = preidstmt.execute!("#{titles[i]}", "#{artists[i]}")
					id = preid[0][0]
					
					# attaching album ID from master table to genre table
					putidstmt = DB.prepare("UPDATE [#{link.genre}_albums] SET album_id = (?) WHERE albumtitle = ? AND artist = ?")			
					putid = putidstmt.execute!("#{id}", "#{titles[i]}", "#{artists[i]}")
				
				rescue StandardError => e
					puts "Problem looking up ID for #{titles[i]} by #{artists[i]}. Moving on with no ID..."
					puts e
					next
				end
			end
		end
	end
end
