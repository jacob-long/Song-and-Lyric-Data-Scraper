require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'date'

require_relative 'linkfeeder'
require_relative 'linkclass'
require_relative 'dbcalls'

class Parse

  def initialize(food)
    @food = food
  end

  attr_accessor :food

  # I need an array of Link objects on which to run chart_parse in an each loop
  def chart_parse_songs
    food.list.each do |link|
      retries = 3
      begin

        # Grabbing the chart page from billboard.com
        page2 = Nokogiri::HTML(open(link.url, 'User-Agent' => 'ruby'))
        puts "Parsing...#{link.genre}: #{link.date}"

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
          x.gsub!(/'/, '\'\'')
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
          x.gsub!(/'/, '\'\'')
        end

        # Making sure there are no errors parsing song titles and artist names.
        if titles.count == artists.count
          upperbound = titles.count
        else
          puts "Number of titles and artists don't match!"
        end

        # Retrieving, grooming, and storing each song's Spotify ID (if one exists).
        spotifyids = []
        (1...upperbound+1).each { |q|
          begin
            pageparse3 = page2.css("main#main.page-content div.chart-data div.container article#row-#{q}.chart-row div.row-primary a.spotify")
            spotifyids.push(pageparse3[0]['href'])
          rescue
            # puts "No Spotify entry found."
            spotifyids.push('None')
            next
          end
        }

        spotifyids.each do |x|
          x.gsub!(/https:\/\/embed.spotify.com\/\?uri=spotify:track:/, '')
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
          x.gsub!(/Last Week:/, '')
        end

          # Error handling for problems with opening webpages.
      rescue StandardError => e
        puts "\tError: #{e}"
        if retries > 0
          puts "\tCan't access the webpage for #{link.genre_snip} on #{link.date}. Going to try again #{retries} more times"
          retries -= 1
          sleep 1
          retry
        else
          puts "\t\tCouldn't access on further attempts, either. Try visiting #{link.url}"
          next
        end
      end

      # Inserts songs into master table that contains all songs
      (0...upperbound).each do |i|
        begin
          DB.execute("INSERT INTO master(songtitle, artist, spotifyid) VALUES ('#{titles[i]}', '#{artists[i]}', '#{spotifyids[i]}')")
        rescue SQLite3::ConstraintException
          next
        rescue StandardError => e
          puts "Error: Check if number of titles and artists match for the #{link.genre_snip} genre on #{link.date}."
          puts e
        end
      end

      # Inserts songs into genre-named table.
      (0...upperbound).each do |i|
        begin
          DB.execute("INSERT INTO [#{link.genre}](songtitle, artist, genre_bb, date, year, week, rank, rank_last)
						VALUES ('#{titles[i]}', '#{artists[i]}', '#{link.genre_snip}', '#{link.url}',
						'#{link.year}', '#{link.week}', '#{ranks[i]}', '#{ranks_last[i]}') ")
        rescue SQLite3::ConstraintException
          next
        rescue StandardError => e
          puts "Error: Check if number of titles and artists match for the #{link.genre_snip} genre on #{link.date}."
          puts e
        end
        begin
          # prevents lookup errors due to apostrophe
          titles[i].gsub!(/''/, '\'')
          artists[i].gsub!(/''/, '\'')

          # grabbing song ID from master table
          # noinspection RubyQuotedStringsInspection
          preidstmt = DB.prepare("SELECT id FROM master WHERE songtitle LIKE ? AND artist LIKE ?")
          preid = preidstmt.execute!("#{titles[i]}", "#{artists[i]}")
          id = preid[0][0]

          # attaching song ID from master table to genre table
          putidstmt = DB.prepare("UPDATE [#{link.genre}] SET song_id = (?) WHERE songtitle = ? AND artist = ?")
          putidstmt.execute!("#{id}", "#{titles[i]}", "#{artists[i]}")

          # Marking the song as charting on singles chart
          DB.execute("UPDATE master SET from_album_song = 'FALSE' AND from_album_chart = 'FALSE' WHERE id = ?", id)

        rescue StandardError => e
          puts "Problem looking up ID for #{titles[i]} by #{artists[i]}. Moving on with no ID..."
          puts e
          next
        end
      end
    end
  end

  def chart_parse_albums
    food.list.each do |link|
    retries = 3
    begin

      # Grabbing the chart page from billboard.com
      page2 = Nokogiri::HTML(open(link.url, 'User-Agent' => 'ruby'))
      puts "Parsing...#{link.genre}: #{link.date}"

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
          spotifyids.push(nil)
          next
        end
      end

      spotifyids.each do |x|
        begin
          x.gsub!(/https:\/\/embed.spotify.com\/\?uri=spotify\:album\:/, '')
        rescue StandardError => e
          puts e
          next
        end
      end

      # Retrieving, grooming, and storing each album's rank on that week's list.
      ranks = []
      rankspre = page2.css('main#main.page-content div.chart-data div.container article.chart-row div.row-primary div.row-rank span.this-week')
      rankspre.each do |x|
        ranks.push(x.text)
      end

      # Retrieving, grooming, and storing each album's rank on that week's list.
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
        puts "\tCan't access the webpage for #{link.genre} on #{link.date}. Going to try again #{retries} more times"
        retries -= 1
        sleep 1
        retry
      else
        puts "\t\tCouldn't access on further attempts, either. Try visiting #{link.url}"
        next
      end
    end

    # Inserts albums into master table that contains all songs
    for i in 0...upperbound do
      begin
        # DB.execute("INSERT INTO album_master(albumtitle, artist, spotifyid) VALUES ('#{titles[i]}', '#{artists[i]}', '#{spotifyids[i]}')")
        DB.execute("INSERT INTO album_master(albumtitle, artist, spotifyid) VALUES (?, ?, ?)", "#{titles[i]}", "#{artists[i]}", spotifyids[i])
      rescue SQLite3::ConstraintException
        next
      rescue StandardError => e
        puts "Error: Check if number of titles and artists match for the #{link.genre} genre on #{link.date}."
        puts e
        next
      end
    end

    # Inserts albums into genre-named table.
    for i in 0...upperbound do
      begin
        DB.execute("INSERT INTO [#{link.genre}_albums](albumtitle, artist, genre_bb, date, year, week, rank, rank_last)
						VALUES ('#{titles[i]}', '#{artists[i]}', '#{link.genre_snip}', '#{link.date}',
						'#{link.year}', '#{link.week}', '#{ranks[i]}', '#{ranks_last[i]}') ")
      rescue SQLite3::ConstraintException
        next
      rescue StandardError=>e
        puts "Error: Check if number of titles and artists match for the #{link.genre} genre on #{link.date}."
        puts e
        next
      end
      begin
        # prevents lookup errors due to apostrophe
        # titles[i].gsub!(/\'\'/, '\'')
        # artists[i].gsub!(/\'\'/, '\'')

        # grabbing album ID from master table
        preidstmt = DB.prepare("SELECT id FROM album_master WHERE albumtitle LIKE ? AND artist LIKE ?")
        preid = preidstmt.execute!(titles[i], artists[i])
        id = preid[0][0]

        # attaching album ID from master table to genre table
        putidstmt = DB.prepare("UPDATE [#{link.genre}_albums] SET album_id = (?) WHERE albumtitle = ? AND artist = ?")
        putid = putidstmt.execute!(id, titles[i], artists[i])

      rescue StandardError => e
        puts "Problem looking up ID for #{titles[i]} by #{artists[i]}. Moving on with no ID..."
        puts e
        next
      end
    end
  end

  end

end