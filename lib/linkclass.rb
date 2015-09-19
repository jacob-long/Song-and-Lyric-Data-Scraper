require 'rubygems'
require 'bundler/setup'

require 'Date'
require 'sqlite3'
require 'Nokogiri'
require 'open-uri'

require_relative 'dbcalls'

class Link 

	def initialize
	end

	attr_accessor :genre, :artist, :week, :year
	
	attr_reader :album, :genre_snip, :date, :date_snip, :url

	def url_genre
		# pop
		if genre == 'pop' and year >= 1992
			then @genre_snip = 'pop-songs'
			@album = false

		elsif genre == 'pop' and year < 1992
			then @genre_snip = 'adult-contemporary'
			@album = false

		# country
		elsif genre == 'country'
		then @genre_snip = 'country-songs'
			@album = false

		# rock
		elsif genre == 'rock' and year >= 2008
			then @genre_snip = 'rock-songs'
			@album = false

		elsif genre == 'rock' and year < 2008
			then @genre_snip = 'hot-mainstream-rock-tracks'
			@album = false

		# R&B / hip hop
		elsif genre == 'R&B/hip hop'
		then @genre_snip = 'r-b-hip-hop-songs'
			@album = false

		# Dance/electronic
		elsif genre == 'dance/electronic' and year >= 2013
			then @genre_snip = 'dance-electronic-songs'
			@album = false

		elsif genre == 'dance/electronic' and year >= 2010 && year < 2013
			then @genre_snip = 'dance-electronic-digital-songs'
			@album = false

		elsif genre == 'dance/electronic' and year < 2010
			then @genre_snip = 'dance-club-play-songs'
			@album = false

		# rap
		elsif genre == 'rap' and year >= 1989
			then @genre_snip = 'rap-song'
			@album = false

		# latin
		elsif genre == 'latin' and year >= 1986
			then @genre_snip = 'latin-songs'
			@album = false

		# christian
		elsif genre == 'christian' and year >= 2003
			then @genre_snip = 'christian-songs'
			@album = false

		else 
		end
	end

	def url_albums
		
		# christian
		if genre == 'christian' and year >=2000
			then @genre_snip = 'christian-albums'
			@album = true
			
		# blues
		elsif genre == 'blues' and year >= 1995
			then @genre_snip = 'blues-albums'
			@album = true

		# classical
		elsif genre == 'classical' and year >= 2000
			then @genre_snip = 'classical-albums'
			@album = true

		# jazz
		elsif genre == 'jazz' and year >= 2000
			then @genre_snip = 'jazz-albums'
			@album = true

		# new age
		elsif genre == 'new age' and year >= 1988
			then @genre_snip = 'new-age-albums'
			@album = true

		# reggae
		elsif genre == 'reggae' and year >= 1994
			then @genre_snip = 'reggae-albums'
			@album = true

		# rock
		elsif genre == 'rock' and year >=2006
			then @genre_snip = 'rock-albums'
			@album = true

		# r&b/hip-hop
		elsif genre == 'R&B/hip hop' and year >=2002
			then @genre_snip = 'r-b-hip-hop-albums'
			@album = true

		# dance/electronic
		elsif genre == 'dance/electronic' and year >=2001
			then @genre_snip = 'dance-electronic-albums'
			@album = true

		# latin
		elsif genre == 'latin' and year >=1993
			then @genre_snip = 'latin-albums'
			@album = true

		# country
		elsif genre == 'country' and year >=2000
			then @genre_snip = 'country-albums'
			@album = true

		# rap
		elsif genre == 'rap' and year >=2004
			then @genre_snip = 'rap-albums'
			@album = true

		else
			puts 'Genre or year is incompatible'
			exit
		end
	end 

	# not sure I'm going to use this
	# def genre_get
	# 	puts "Please enter the genre"
	# 	while genre = gets.chomp
	# 		case genre
	# 		when "pop"
	# 			puts "valid response"
	# 			break
	# 		else
	# 			"invalid genre, try again"
	# 		end
	# 	end
	# end

	def date_get
		@year = year
		@week = week
		@date = Date.commercial(year, week, 6)
	end

	def date_snip
		@date_snip = date
	end

	def url_make
		@url = "http://billboard.com/charts/#{genre_snip}/#{date_snip}"
	end


end


