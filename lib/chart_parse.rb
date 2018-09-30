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

    genre = nil
    prog_bar = ProgressBar.create(:title => "Song charts progress",
									   :starting_at => 0,
                      :total => food.list.length)
                      
    food.list.each do |link|
      retries = 3
      begin

        if genre != link.genre
          prog_bar.log "Parsing #{link.genre} songs... "
          genre = link.genre
        end
  
        # Grabbing the chart page from billboard.com
        if (retries < 3) == true
          page2 = Nokogiri::HTML(open(link.url, 'User-Agent' => 'ruby'))
        else 
          # print "#{link.date}..."
          page2 = Nokogiri::HTML(open(link.url))
        end

        # Fetching songtitles
        the_songs = page2.css('div.chart-list-item')

        # Grooming and storing songtitle entries.
        titles = []
        artists = [] 
        ranks = []
        the_songs.each do |x|
          titles.push(x['data-title'])
          artists.push(x['data-artist'])
          ranks.push(x['data-rank'])
        end

        titles.each do |x|
          x.lstrip!
          x.rstrip!
          x.gsub!(/'/, '\'\'')
        end

        artists.each do |x|
          x.lstrip!
          x.rstrip!
          x.gsub!(/'/, '\'\'')
        end

        # Retrieving, grooming, and storing each song's rank on that week's list.
        ranks_last = []
        ranks_last_pre = page2.css('chart-list-item__last-week')
        ranks_last_pre.each do |x|
          ranks_last.push(x.text)
        end

        # Deal with number ones
        titles.push(page2.css('chart-number-one__title').text)
        artists.push(page2.css('chart-number-one__artist').text)
        ranks.push("1")
        one_last_rank = page2.css('.chart-number-one__last-week').text
        if one_last_rank == ""
          one_last_rank = "1"
        end
        ranks_last.push(one_last_rank)

        # Making sure there are no errors parsing song titles and artist names.
        if titles.count == artists.count
          upperbound = titles.count
        else
          prog_bar.log "Number of titles and artists don't match!"
        end

      # Error handling for problems with opening webpages.
      rescue OpenURI::HTTPError => e
        if retries > 0 and retries < 3
          prog_bar.log "\nError: #{e}"
          prog_bar.log "\nCan't access the webpage for #{link.genre} on #{link.date}. Going to try again #{retries} more times"
          retries -= 1
          sleep 1 + (3 - retries) * 2
          retry
        elsif retries == 3
          retries -= 1
          retry
        else
          prog_bar.log "\n\nCouldn't access on further attempts, either. Try visiting #{link.url}"
          prog_bar.increment
          next
        end

      rescue Net::OpenTimeout => e
        if retries > 0 and retries < 3
          prog_bar.log "\nError: #{e}"
          prog_bar.log "\nCan't access the #{link.genre} webpage on #{link.date}. Going to try again #{retries} more times"
          retries -= 1
          sleep 1 + (3 - retries) * 2
          retry
        elsif retries == 3
          retries -= 1
          retry
        else
          prog_bar.log "\n\nCouldn't access on further attempts, either. Try visiting #{link.url}"
          prog_bar.increment
          next
        end

      rescue StandardError => e
        if retries > 0 and retries < 3
          prog_bar.log "\nError: #{e}"
          prog_bar.log "\nCan't access the #{link.genre} webpage on #{link.date}. Going to try again #{retries} more times"
          retries -= 1
          sleep 1 + (3 - retries) * 2
          retry
        elsif retries == 3
          retries -= 1
          retry
        else
          prog_bar.log "\n\nCouldn't access on further attempts, either. Try visiting #{link.url}"
          prog_bar.increment
          next
        end  
      end

      # Inserts songs into master table that contains all songs
      (0...upperbound).each do |i|
        begin
          DB.execute("INSERT INTO master(songtitle, artist) VALUES ('#{titles[i]}', '#{artists[i]}')")
        rescue SQLite3::ConstraintException
          next
        rescue StandardError => e
          prog_bar.log "Error: Check if number of titles and artists match for the #{link.genre_snip} genre on #{link.date}."
          prog_bar.log e
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

      prog_bar.increment

    end
  end

  def chart_parse_albums

    genre = nil
    prog_bar = ProgressBar.create(:title => "Album charts progress",
									   :starting_at => 0,
                      :total => food.list.length)
                      
    food.list.each do |link|
    retries = 3
    begin

      if genre != link.genre
        prog_bar.log "Parsing #{link.genre} albums..."
        genre = link.genre
      end

      # Grabbing the chart page from billboard.com
      if (retries < 3) == true
        page2 = Nokogiri::HTML(open(link.url, 'User-Agent' => 'ruby'))
      else 
        page2 = Nokogiri::HTML(open(link.url))
      end

      # Fetching titles
      the_albums = page2.css('div.chart-list-item')

      # Grooming and storing songtitle entries.
      titles = []
      artists = [] 
      ranks = []
      the_albums.each do |x|
        titles.push(x['data-title'])
        artists.push(x['data-artist'])
        ranks.push(x['data-rank'])
      end

      titles.each do |x|
        x.lstrip!
        x.rstrip!
        x.gsub!(/'/, '\'\'')
      end

      artists.each do |x|
        x.lstrip!
        x.rstrip!
        x.gsub!(/'/, '\'\'')
      end

      # Retrieving, grooming, and storing each song's rank on that week's list.
      ranks_last = []
      ranks_last_pre = page2.css('chart-list-item__last-week')
      ranks_last_pre.each do |x|
        ranks_last.push(x.text)
      end

      # Deal with number ones
      titles.push(page2.css('chart-number-one__title').text)
      artists.push(page2.css('chart-number-one__artist').text)
      ranks.push("1")
      one_last_rank = page2.css('.chart-number-one__last-week').text
      if one_last_rank == ""
        one_last_rank = "1"
      end
      ranks_last.push(one_last_rank)

      # Making sure there are no errors parsing song titles and artist names.
      if titles.count == artists.count
        upperbound = titles.count
      else
        prog_bar.log "Number of titles and artists don't match!"
      end

    # Error handling for problems with opening webpages.
    rescue OpenURI::HTTPError => e
      if retries > 0 and retries < 3
        prog_bar.log "\nError: #{e}"
        prog_bar.log "\nCan't access the webpage for #{link.genre} albums on #{link.date}. Going to try again #{retries} more times"
        retries -= 1
        sleep 1 + (3 - retries) * 2
        retry
      elsif retries == 3
        retries -= 1
        retry
      else
        prog_bar.log "\n\nCouldn't access on further attempts, either. Try visiting #{link.url}"
        prog_bar.increment
        next
      end
    
    rescue Net::OpenTimeout => e
      if retries > 0 and retries < 3
        prog_bar.log "\nError: #{e}"
        prog_bar.log "\nCan't access the #{link.genre} webpage on #{link.date}. Going to try again #{retries} more times"
        retries -= 1
        sleep 1 + (3 - retries) * 2
        retry
      elsif retries == 3
        retries -= 1
        retry
      else
        prog_bar.log "\n\nCouldn't access on further attempts, either. Try visiting #{link.url}"
        prog_bar.increment
        next
      end
    end

    # Inserts albums into master table that contains all songs
    for i in 0...upperbound do
      begin
        # DB.execute("INSERT INTO album_master(albumtitle, artist, spotifyid) VALUES ('#{titles[i]}', '#{artists[i]}', '#{spotifyids[i]}')")
        DB.execute("INSERT INTO album_master(albumtitle, artist) VALUES (?, ?)", "#{titles[i]}", "#{artists[i]}")
      rescue SQLite3::ConstraintException
        next
      rescue StandardError => e
        prog_bar.log "Error: Check if number of titles and artists match for the #{link.genre} genre on #{link.date}."
        prog_bar.log e
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
      rescue StandardError => e
        prog_bar.log "Error: Check if number of titles and artists match for the #{link.genre} genre on #{link.date}."
        prog_bar.log e
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
        prog_bar.log "Problem looking up ID for #{titles[i]} by #{artists[i]}. Moving on with no ID..."
        prog_bar.log e
        next
      end
    end

    prog_bar.increment

  end

  end

end