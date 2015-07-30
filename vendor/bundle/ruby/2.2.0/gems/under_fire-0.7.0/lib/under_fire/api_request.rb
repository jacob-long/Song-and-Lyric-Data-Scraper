require 'net/http'
require 'net/https'
require 'uri'
require 'open-uri'

module UnderFire
  # HTTP requests required for Gracenote API.
  #
  # @todo Error handling
  #
  # @example
  #   response = UnderFire::ApiRequest.post(query_xml, api_url)
  #
  #   response = UnderFire::ApiRequest.get_file(image_url, filename)
  class APIRequest
    # @param [String] query XML query string
    # @param [String] api_url url for your application
    # @return [Net::HTTPResponse]
    def self.post(query, api_url)
      uri = URI(api_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.ssl_version = 'SSLv3'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.request_uri)
      req.body = query
      req['Content-Type'] = 'application/xml'
      res = http.request(req)
      res
    end

    # @param [String] url URL that points to file.
    # @param [String] filename Filename and path for saving downloaded file.
    def self.get_file(url, filename)
      uri = URI url

      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri

        http.request request do |response|
          open filename, 'w' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    end
  end
end
