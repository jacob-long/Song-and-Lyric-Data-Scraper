require 'rubygems'
require 'bundler/setup'

module Metaclean
  
  def self.artist_clean(artist)
    artist.slice!(/.Featuring.*$/)
    artist.slice!(/.With.*$/)
    artist.slice!(/.\&amp\;.*$/)
    artist.slice!(/,.*$/)
    artist.slice!(/.\&.*$/)
    artist.gsub!(/\$/, 'S')
    artist.delete!('-')
    artist.delete!('\'')
    artist.gsub!(/"([^"]*)"./, '')
  end
  
  def self.title_clean(title)
    title.delete! '.'
    title.delete! '!'
    title.delete! '#'
    title.delete! '+'
    title.delete! ','
    title.delete! '\''
    title.slice!(/.\(.*$/)
    title.gsub!(/\&amp\;/, '&')
    title.gsub!(/\&\#039\;/, '\'')
    title.gsub!(/F\*\*k/, 'Fuck')
    title.gsub!(/S\*\*t/, 'Shit')
  end
end
