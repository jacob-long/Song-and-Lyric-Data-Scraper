require 'rubygems'
require 'bundler/setup'

require 'sqlite3'

module Summarize

  def self.singles(genre, dbname)

    db = SQLite3::Database.open(dbname)

    numerator = db.execute("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [#{genre}] ON master.id = [#{genre}].song_id
      WHERE (master.lyrics_w NOT NULL or master.lyrics_w != '') OR (master.lyrics_ml NOT NULL or master.lyrics_ml != '')")

    denominator = db.execute("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [#{genre}] ON master.id = [#{genre}].song_id")

    numerator = Float(numerator[0][0])
    denominator = Float(denominator[0][0])
    percentage = (numerator/denominator)

    puts "I have lyrics for #{percentage} of singles in #{genre} (#{denominator} total tracks)."
  end

  def self.with_albums(genre, dbname)
    db = SQLite3::Database.open(dbname)

    begin
    numerator = db.execute("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [#{genre}] ON master.id = [#{genre}].song_id
      WHERE (master.lyrics_w NOT NULL or master.lyrics_w != '') OR (master.lyrics_ml NOT NULL or master.lyrics_ml != '')")

    denominator = db.execute("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [#{genre}] ON master.id = [#{genre}].song_id")

    numerator = Float(numerator[0][0])
    denominator = Float(denominator[0][0])

    rescue
      numerator = Float(0)
      denominator = Float(0)
    end

    numerator2 = db.execute("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [#{genre}_albums] ON master.album_id = [#{genre}_albums].album_id
      WHERE (master.lyrics_w NOT NULL or master.lyrics_w != '') OR (master.lyrics_ml NOT NULL or master.lyrics_ml != '') AND master.from_album_chart = 'true'")

    denominator2 = db.execute("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [#{genre}_albums] ON master.album_id = [#{genre}_albums].album_id
      WHERE master.from_album_chart = 'true'")

    numerator2 = Float(numerator2[0][0])
    denominator2 = Float(denominator2[0][0])

    final_numerator = numerator + numerator2
    final_denominator = denominator + denominator2

    percentage = final_numerator/final_denominator

    puts "I have lyrics for #{percentage} of total tracks in #{genre} (#{final_denominator} total tracks)."
  end

  def self.albums_fetched(genre, dbname)

    db = SQLite3::Database.open(dbname)

    numerator = db.execute("SELECT COUNT(DISTINCT master.album_id) FROM master
      JOIN [#{genre}_albums] ON master.album_id = [#{genre}_albums].album_id")

    numerator = Float(numerator[0][0])

    denominator = db.execute("SELECT COUNT(DISTINCT album_master.id) FROM album_master
      JOIN [#{genre}_albums] ON album_master.id = [#{genre}_albums].album_id")

    denominator = Float(denominator[0][0])

    percentage = numerator/denominator

    puts "I found #{percentage} of tracklists for #{genre} albums"

  end

end