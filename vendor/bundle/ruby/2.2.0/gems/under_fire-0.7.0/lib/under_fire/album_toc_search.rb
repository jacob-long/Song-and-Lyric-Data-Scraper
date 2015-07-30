require 'under_fire/base_query'
require 'builder'

module UnderFire
  # Builds XML for Gracenote's ALBUM_TOC query
  #
  # @see 'https://developer.gracenote.com/sites/default/files/web/html/index.html#Music%20Web%20API/ALBUM_TOC.html#_Toc344907258'
  #
  # @example
  #   search = UnderFire::AlbumTOCSearch.new(:toc => '182 10762 22515 32372 43735 53335 63867 78305 89792 98702 110612 122590 132127 141685')
  #   search.query #=> XML query string for ALBUM_TOC query.
  class AlbumTOCSearch < BaseQuery
    # @return [String] CD Table of contents.
    attr_reader :toc

    # @return [String] XML string for ALBUM_TOC query.
    attr_reader :query

    # :toc is required (:mode is optional).
    #
    # @param [Hash] args arguments to create an ALBUM_TOC query.
    # @option [String] :toc CD table of contents (space-separated list of track start frames)
    # @option [String] :mode Either 'SINGLE_BEST' or 'SINGLE_BEST_COVER'
    def initialize(args)
      super args[:mode]
      @toc = args[:toc]
      @query = build_query
    end

    # Builds TOC-specific part of ALBUM_TOC query and adds it to the base query
    # common to all query types. Called by constructor.
    #
    # @return [String] XML string for ALBUM_TOC query.
    def build_query
      build_base_query do |builder|
        builder.QUERY(CMD: "ALBUM_TOC"){
          builder.MODE mode
          builder.TOC {
            builder.OFFSETS toc.to_s
          }
        }
      end
    end
  end
end
