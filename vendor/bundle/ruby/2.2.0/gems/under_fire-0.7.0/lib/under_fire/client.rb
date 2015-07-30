require 'under_fire/album_search'
require 'under_fire/album_toc_search'
require 'under_fire/album_fetch'
require 'under_fire/api_request'
require 'under_fire/api_response'
require 'under_fire/configuration'

require 'pry'

module UnderFire
  # Public interface to UnderFire's functionality.
  #
  # @example
  #   client = UnderFire::Client.new
  #   client.album_search(:artist => 'Miles Davis') #=> lots of results
  #
  #   client = UnderFire::Client.new
  #   client.find_by_toc space_delimited_toc_offsets
  class Client
    include UnderFire

    # @return [String] API URL for application.
    attr_reader :api_url

    def initialize
      @api_url = Configuration.instance.api_url
    end

    # Searches for album using provided toc offsets.
    # @return [APIResponse]
    # @see UnderFire::AlbumTOCSearch
    def find_by_toc(*offsets)
      offsets = offsets.join(" ")
      search = AlbumTOCSearch.new(:toc => offsets)
      response = APIRequest.post(search.query, api_url)
      APIResponse.new(response.body)
    end

    # Finds album using one or more of :artist, :track_title and :album_title
    # @return [APIResponse]
    # @see UnderFire::AlbumSearch Description of arguments.
    def find_album(args)
      search = AlbumSearch.new(args)
      response = APIRequest.post(search.query, api_url)
      APIResponse.new(response.body)
    end

    # Fetches album with given album :gn_id or track :gn_id
    # @return [APIResponse]
    # @see UnderFire::AlbumFetch Description of arguments.
    def fetch_album(args)
      search = AlbumFetch.new(args)
      response = APIRequest.post(search.query, api_url)
      APIResponse.new(response.body)
    end

    # Registers user with given client_id
    # @return [APIResponse]
    # @see UnderFire::Registration Description of arguments
    def register(client_id)
      search = Registration.new(client_id)
      response = APIRequest.post(search.query, api_url)
      APIResponse.new(response.body)
    end

    # Fetches cover art using results of query.
    # @param [APIResponse] response
    def fetch_cover(response, file_name)
      res = response.to_h
      response_url = res['RESPONSE']['ALBUM']['URL']
      title = res['RESPONSE']['ALBUM']['TITLE']
      file_name = file_name || "#{title}-cover.jpg"

      APIRequest.get_file(response_url, filename)
    end
  end
end
