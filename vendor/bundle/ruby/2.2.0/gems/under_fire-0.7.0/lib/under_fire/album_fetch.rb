require 'under_fire/base_query'
require 'builder'

module UnderFire
  # Builds XML for Gracenote's ALBUM_FETCH query.
  #
  # @see https://developer.gracenote.com/sites/default/files/web/html/index.html#Music%20Web%20API/ALBUM_FETCH.html#_Toc344907262
  #
  # @example
  #   search = UnderFire::Album_Fetch.new(:gn_id => '86372321-2C7F28ADC369EB90E53A7F6CA3A70D56')
  #   search.query => Response = The Beatles, Help!
  class AlbumFetch < BaseQuery
    # @return [String] XML string for query.
    attr_reader :query

    # @return [Hash] Search parameters with :mode removed.
    attr_reader :parameters

    # @return [String] Gracenote ID for album
    attr_accessor :gn_id

    # Requires album :gn_id or track :gn_id
    #
    # @param [Hash] args the arguments for Album_Fetch
    # @option args [String] :gn_id Gracenote ID of album or track
    # @option args [String] :mode Either 'SINGLE_BEST' or 'SINGLE_BEST_COVER'
    #   (Only needed if track :gn_id used)
    def initialize(args)
      super args
      @parameters = args.reject {|k,v| k == :mode}
      parameters.each do |k,v| send("#{k}=", v) end
      @query = build_query
    end

    # Builds ALBUM_FETCH-specific part of ALBUM_FETCH query and adds it to the base query
    # common to all query types. Called by constructor.
    #
    # @return [String] XML string for ALBUM_FETCH query.
    def build_query
      build_base_query do |builder|
        builder.QUERY(cmd: "ALBUM_FETCH"){
          builder.MODE "SINGLE_BEST_COVER"
          parameters.each do |k,v|
            builder.GN_ID gn_id
          end
        }
      end
    end
  end
end
