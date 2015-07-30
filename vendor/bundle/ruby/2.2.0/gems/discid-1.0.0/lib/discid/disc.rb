# Copyright (C) 2013 Philipp Wolfer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'ffi'
require 'discid/lib'
require 'discid/track'

module DiscId
  # This class holds information about a disc (TOC, MCN, ISRCs).
  #
  # Use {DiscId#read} or {DiscId#put} to initialize an instance of {Disc}.
  class Disc

    # The device from which this disc object was read.
    attr_reader :device

    # @private
    def initialize
      pointer = Lib.new
      @handle = FFI::AutoPointer.new(pointer, Lib.method(:free))
      @read = false
      @tracks = nil
    end

    # @private
    def read(device, *features)
      @read = false
      device = DiscId.default_device if device.nil?
      
      if not device.respond_to? :to_s
        raise TypeError, 'wrong argument type (expected String)'
      end
     
      @device = device.to_s
      flags = Lib.features_to_int features
      result = Lib.read @handle, @device, flags

      if result == 0
        raise DiscError, Lib.get_error_msg(@handle)
      else
        @read = true
      end
    end

    # @private
    def put(first_track, sectors, offsets)
      @read = false
      @device = nil
      last_track = offsets.length - 1 + first_track
      
      # discid_put expects always an offsets array with exactly 100 elements.
      FFI::MemoryPointer.new(:int, 100) do |p|
        p.write_array_of_int([sectors] + offsets)
        result = Lib.put @handle, first_track, last_track, p
        
        if result == 0
          raise DiscError, Lib.get_error_msg(@handle)
        else
          @read = true
        end
      end
    end

    # The MusicBrainz DiscID.
    #
    # @return [String] The DiscID or `nil` if no ID was yet read.
    def id
      return Lib.get_id @handle if @read
    end

    # The FreeDB DiscID.
    #
    # @return [String] The DiscID or  `nil` if no ID was yet read.
    def freedb_id
      return Lib.get_freedb_id @handle if @read
    end
    
    # The number of the first track on this disc.
    # 
    # @return [Integer] The number of the first track or `nil` if no ID was yet read. 
    def first_track_number
      return Lib.get_first_track_num @handle if @read
    end

    # The number of the last track on this disc.
    # 
    # @return [Integer] The number of the last track or `nil` if no ID was yet read. 
    def last_track_number
      return Lib.get_last_track_num @handle if @read
    end

    # The length of the disc in sectors.
    # 
    # @return [Integer] Sectors or `nil` if no ID was yet read. 
    def sectors
      return Lib.get_sectors @handle if @read
    end

    # The length of the disc in seconds.
    # 
    # @return [Integer] Seconds or `nil` if no ID was yet read. 
    def seconds
      DiscId.sectors_to_seconds(sectors) if @read
    end

    # The media catalogue number on the disc, if present.
    #
    # Requires libdiscid >= 0.5. If not supported this method will always
    # return `nil`.
    #
    # @note libdiscid >= 0.3.0 required. Older versions will always return nil.
    #     Not available on all platforms, see
    #     {http://musicbrainz.org/doc/libdiscid#Feature_Matrix}.
    #
    # @return [String] MCN or `nil` if no ID was yet read. 
    def mcn
      return Lib.get_mcn @handle if @read
    end

    # An URL for submitting the DiscID to MusicBrainz.
    #
    # The URL leads to an interactive disc submission wizard that guides the
    # user through the process of associating this disc's DiscID with a release
    # in the MusicBrainz database.
    #
    # @return [String] Submission URL
    def submission_url
      return Lib.get_submission_url @handle if @read
    end

    # DiscID to String conversion. Same as calling the method {#id} but guaranteed
    # to return a string.
    #
    # @return [String] The disc ID as a string or an empty string if no ID
    #     was yet read.
    def to_s
      id.to_s
    end

    # Returns an array of {Track} objects. Each Track object contains
    # detailed information about the track.
    # 
    # Returns always `nil` if no ID was yet read. The block won't be
    # called in this case.
    #
    # @yield [track_info] If a block is given this method returns `nil` and
    #     instead iterates over the block calling the block with one argument.
    # @yieldreturn [nil]
    # @return [Array<Track>] Array of {Track} objects.
    def tracks
      if @read
        read_tracks if @tracks.nil?
        
        if block_given?
          @tracks.each(&Proc.new)
          return nil
        else
          return @tracks
        end
      end
    end

    private

    def read_tracks
      track_number = self.first_track_number - 1
      @tracks = []
      
      while track_number < self.last_track_number do
        track_number += 1
        isrc = Lib.get_track_isrc(@handle, track_number)
        offset = Lib.get_track_offset(@handle, track_number)
        length = Lib.get_track_length(@handle, track_number)
        track_info = Track.new(track_number, offset, length, isrc)
        
        @tracks << track_info
      end
    end

  end

  # This exception is thrown on errors reading the disc or setting the TOC.
  class DiscError < StandardError
  end
end
