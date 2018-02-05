require 'rubygems'
require 'bundler/setup'

require 'sqlite3'

require_relative 'linkclass'

class DBcalls
	def self.create_genre_table linkgenre
		DB.execute("CREATE TABLE IF NOT EXISTS [#{linkgenre}]
			(
				id INTEGER PRIMARY KEY AUTOINCREMENT, 
				songtitle TEXT,
				artist TEXT,
				genre_bb TEXT,
				date TEXT,
				year TEXT,
				week TEXT,
				rank INTEGER,
				rank_last INTEGER,
				song_id INTEGER,
				UNIQUE (songtitle, artist, date, genre_bb)
			)"
		)
	end

	def self.create_table_master
		DB.execute("CREATE TABLE IF NOT EXISTS master
			(
				id INTEGER PRIMARY KEY AUTOINCREMENT, 
				songtitle TEXT, 
				alt_songtitle TEXT,
				artist TEXT,
				alt_artist TEXT,
				extra_artists TEXT,
				spotifyid TEXT,
				lyrics_w TEXT,
				lyrics_ml TEXT,
				lyrics_sim_score TEXT,
				album_title TEXT,
				album_id INTEGER,
				num_on_album INTEGER, 
				spotify_album_id NUMERIC,
				spotify_song_run TEXT,
				from_album_chart TEXT,
				from_album_song TEXT,
				artist_location TEXT,
				attributes_run TEXT,
				key INTEGER,
				key_confidence NUMERIC,
				energy NUMERIC,
				liveness NUMERIC,
				loudness NUMERIC,
				audio_md5 TEXT,
				valence NUMERIC,
				danceability NUMERIC,
				tempo NUMERIC,
				tempo_confidence NUMERIC,
				speechiness NUMERIC,
				acousticness NUMERIC,
				instrumentalness NUMERIC,
				mode INTEGER,
				mode_confidence NUMERIC,
				time_signature INTEGER,
				time_signature_confidence NUMERIC,
				duration NUMERIC,
				analysis_url TEXT,
				ISRC NUMERIC,
				UNIQUE(songtitle COLLATE NOCASE, artist COLLATE NOCASE),
				UNIQUE(songtitle, artist),
				UNIQUE(songtitle COLLATE NOCASE, album_title COLLATE NOCASE),
				UNIQUE(songtitle COLLATE NOCASE, spotify_album_id COLLATE NOCASE)
			)
		")
	end

	def self.create_album_master
		DB.execute("CREATE TABLE IF NOT EXISTS album_master
			(
				id INTEGER PRIMARY KEY AUTOINCREMENT, 
				albumtitle TEXT,
				alt_albumtitle TEXT,
				artist TEXT,
				alt_artist TEXT,
				spotifyid NUMERIC,
				discogsid NUMERIC,
				from_single TEXT,
				discogsrun TEXT,
				spotify_run TEXT,
				catnum NUMERIC,
				UNIQUE(albumtitle, artist),
				UNIQUE(albumtitle COLLATE NOCASE, artist COLLATE NOCASE),
				UNIQUE(spotifyid COLLATE NOCASE)
			)"
		)
	end

	def self.create_album_genre linkgenre
		DB.execute("CREATE TABLE IF NOT EXISTS [#{linkgenre}_albums]
			(
				id INTEGER PRIMARY KEY AUTOINCREMENT, 
				albumtitle TEXT,
				artist TEXT,
				genre_bb TEXT,
				date TEXT,
				year TEXT,
				week TEXT,
				rank INTEGER,
				rank_last INTEGER,
				album_id INTEGER,
				UNIQUE (albumtitle, artist, date, genre_bb)
			)"
		)
	end

	def grab_songs
		DB.results_as_hash = true
		DB.execute(" SELECT id, artist, songtitle FROM #{link.genre} ")
	end

end


