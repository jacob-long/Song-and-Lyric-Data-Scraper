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

        rescue StandardError => e
          puts "Problem looking up ID for #{titles[i]} by #{artists[i]}. Moving on with no ID..."
          puts e
          next
        end
      end
    end
  end

end