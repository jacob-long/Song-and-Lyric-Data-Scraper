require 'thor'
require 'under_fire/api_request'
require 'under_fire/client'

module UnderFire
  # Command Line interface
  class CLI < Thor
    include UnderFire

    attr_reader :config, :client

    def initialize(*)
      super
      @config = Configuration.instance
      @client = Client.new()
    end

    desc  "toc", "Use provided offsets to query Gracenote for album information."
    method_option :offsets,
      :aliases => '-o',
      :desc => "Specify cd table of contents offsets",
      :required => true,
      :type => :array
    def toc
      say client.find_by_toc(options[:offsets])
    end

    desc "album", "Queries Gracenote with album <title>, <song> title, or <artist> name"
    method_option :album_title,
      :aliases => '-t',
      :desc => "Specify album title",
      :required => false
    method_option :track_title,
      :aliases => ['-s', :song_title],
      :desc => "Specify song title",
      :required => false
    method_option :artist,
      :aliases => '-a',
      :desc => "Specify artist name",
      :required => false
    def album
      say client.find_album(options)
    end

    desc "id", "Not yet implemented"
    method_option :gn_id,
      :aliases => ['-i', '--id'],
      :required => true,
      :desc => "Gracenote album or song GN_ID"
    def id
      puts "Not implemented"
    end

    desc "cover", "Gets cover from Gracenote."
    method_option :url,
      :aliases => '-u',
      :required => true,
      :desc => "URL provided by Gracenote for downloading cover image."
    method_option :file_name,
      :aliases => '-f',
      :required => false,
      :desc => "File name for saving image.",
      :default => ""
    method_option :verbose,
      :aliases => '-v',
      :type => :boolean,
      :required => false,
      :default => false
    def cover
      say "Fetching cover" if options[:verbose]
      url = options[:url]
      file_name = options[:file_name].empty? ? "cover.jpg" : options[:file_name]
      APIRequest.get_file(url, file_name)
      say "saved #{file_name} in #{File.dirname __FILE__}" if options[:verbose]
    end

    desc "register", "Registers user with client_id."
    method_option :client_id,
      :aliases => '-c',
      :required => true
    def register
      say client.register(options[:client_id])
    end
  end
end
