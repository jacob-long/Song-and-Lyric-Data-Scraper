require 'rubygems'
require 'bundler/setup'

require 'sqlite3'

genres = ["rap", "R&B/hip hop", "country", "rock", "dance/electronic", "latin", "christian", "blues", "jazz", "new age", "reggae", "classical"]
# years = ["2010"]
# , "2011", "2012", "2013", "2014", "2015"]

DBNAME = "final7.sqlite"
# File.delete(DBNAME) if File.exists?DBNAME

db = SQLite3::Database.open(DBNAME)

db.results_as_hash = true

# Iterating through each genre
genres.each do |genres|

  thing = db.execute("SELECT * FROM [#{genres}_albums] WHERE [#{genres}_albums].album_id IS NULL")

  thing.each do |album|

				begin
				db.execute("INSERT INTO album_master(albumtitle, artist) VALUES (?, ?)", "#{album['albumtitle']}", "#{album['artist']}")
        rescue SQLite3::ConstraintException => e
          puts e
				rescue StandardError => e
					puts e
				end

				begin
					# prevents lookup errors due to apostrophe
					album['albumtitle'].gsub!(/\'\'/, '\'')
					album['artist'].gsub!(/\'\'/, '\'')

					# grabbing album ID from master table
					preidstmt = db.prepare("SELECT id FROM album_master WHERE albumtitle LIKE ? AND artist LIKE ?")
					preid = preidstmt.execute!("#{album['albumtitle']}", "#{album['artist']}")
					id = preid[0][0]
					
					# attaching album ID from master table to genre table
					putidstmt = db.prepare("UPDATE [#{genres}_albums] SET album_id = (?) WHERE albumtitle = ? AND artist = ?")
					putidstmt.execute!("#{id}", "#{album['albumtitle']}", "#{album['artist']}")
				
				rescue StandardError => e
					puts "Problem looking up ID for #{album['albumtitle']} by #{album['artist']}. Moving on with no ID..."
					puts e
					next
        end
	end
end
