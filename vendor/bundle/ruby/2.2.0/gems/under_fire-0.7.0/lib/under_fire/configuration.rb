require 'singleton'

module UnderFire
  # Configuration information.
  class Configuration
    include Singleton

    attr_reader :config_info

    def initialize
      @config_info = load_config
    end

    # Gracenote client id stored in environment variable.
    # @return [String]
    def client_id
      config_info.fetch(:client_id, nil).to_s
    end

    # Part of client id before the hyphen (used by api_url).
    # @return [String]
    def client_id_string
      client_id.split('-')[0]
    end

    # Part of client id after hyphen
    # @return [String]
    def client_tag
      client_id.split('-')[1]
    end

    # Gracenote user id
    # @return [String]
    def user_id
      config_info.fetch(:user_id, nil).to_s
    end

    # Gracenote API url for use in queries.
    # @return [String]
    def api_url
      "https://c#{client_id_string}.web.cddbp.net/webapi/xml/1.0/"
    end

    # Returns true if user has a user_id
    # @return [Boolean]
    def authorized?
      user_id != nil
    end

    # Returns true if user has a client_id and user_id
    # @return [Boolean]
    def configured?
      client_id != nil && !authorized?
    end

    def reset
      initialize
    end

    private

    def load_config
      {:client_id => ENV['GRACENOTE_CLIENT_ID'],
       :user_id => ENV['GRACENOTE_USER_ID']}
    end
  end
end
