require 'under_fire/base_query'
require 'builder'

module UnderFire
  # Builds XML for Gracenote's ALBUM_SEARCH query.
  #
  # @see https://developer.gracenote.com/sites/default/files/web/html/index.html#Music%20Web%20API/ALBUM_SEARCH.html#_Toc344907249
  #
  # @example
  #   search = UnderFire::AlbumSearch.new(:artist => 'Radiohead')
  #   search.query #=> XML for Gracenote ALBUM_SEARCH query for albums by Radiohead.
  #
  #   search = UnderFire::AlbumSearch.new(:track_title = > 'Paranoid Android',
  #                                       :artist => 'Radiohead',
  #                                       :mode => 'SINGLE_BEST_COVER')
  #   search.query #=> XML for ALBUM_SEARCH
  #
  #
  class AlbumSearch < BaseQuery
    # @return [String] XML string for query.
    attr_reader :query

    # @return [Hash] search parameters without :mode
    attr_reader :parameters

    # @return [String]
    attr_accessor :artist

    # @return [String]
    attr_accessor :track_title

    # @return [String]
    attr_accessor :album_title

    # At least one of :artist, :track_title, :album_title is required (:mode is optional).
    #
    # @param [Hash] args the arguments for an Album_Search.
    # @option args [String] :artist Name of the artist.
    # @option args [String] :track_title Name of the song/track.
    # @option args [String] :album_title Name of the album.
    # @option args [String] :mode Either 'SINGLE_BEST' or 'SINGLE_BEST_COVER'
    def initialize(args={})
      super args[:mode]
      @parameters = args.reject {|k,v| k == :mode}
      parameters.each do |k,v| send("#{k}=", v) end
      @query = build_query
    end

    # Builds ALBUM_SEARCH-specific part of ALBUM_SEARCH query and adds it to the base query
    # common to all query types. Called by constructor.
    #
    # @return [String] XML string for ALBUM_SEARCH query.
    def build_query
      build_base_query do |builder|
        builder.QUERY(CMD: "ALBUM_SEARCH"){
          builder.MODE "SINGLE_BEST_COVER"
          parameters.each do |k,v|
            builder.TEXT(v, TYPE: k.to_s.upcase)
          end
        }
      end
    end
  end
end
