require 'rubygems'
require 'bundler/setup'

require 'sqlite3'

module Summarize

  def singles(genre, dbname)

    db = SQLite3::Database.open(dbname)

    statement_numerator = db.prepare("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [?] ON master.id = [?].song_id
      WHERE (master.lyrics_w NOT NULL or master.lyrics_w != '') OR (master.lyrics_ml NOT NULL or master.lyrics_ml != '')")

    numerator = statement_numerator.execute(genre, genre)

    statement_denominator = db.prepare("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [?] ON master.id = [?].song_id")

    denominator = statement_denominator.execute(genre, genre)

    puts "I have lyrics for #{(numerator/denominator)} of singles in #{genre}."
  end

  def with_albums(genre, dbname)
    db = SQLite3::Database.open(dbname)

    statement_numerator = db.prepare("SELECT COUNT(DISTINCT master.id)
      FROM master
      JOIN [?] ON master.album_id = [?].album_id
      WHERE (master.lyrics_w NOT NULL or master.lyrics_w != '') OR (master.lyrics_ml NOT NULL or master.lyrics_ml != '') AND master.from_album_chart = 'true'")

    numerator = statement_numerator.execute("#{genre}_albums", "#{genre}_albums")

    statement_denominator = db.prepare("SELECT COUNT(DISTINCT master.id)
    FROM master
    JOIN [?] ON master.album_id = [?].album_id
    WHERE master.from_album_chart = 'true'")

    denominator = statement_denominator.execute("#{genre}_albums", "#{genre}_albums")

    puts "I have lyrics for #{(numerator/denominator)} of singles in #{genre}."
  end

end