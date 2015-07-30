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

require 'discid/lib'
require 'discid/disc'
require 'discid/version'

# The DiscId module allows calculating DiscIDs (MusicBrainz and freedb)
# for Audio CDs. Additionally the library can extract the MCN/UPC/EAN and
# the ISRCs from disc.
#
# The main interface for using this module are the {read} and {put}
# methods which both return an instance of {Disc}. {read} allows you to
# read the data from an actual CD drive while {put} allows you to
# calculate the DiscID for a previously read CD TOC.
#
# Depending on the version of libdiscid and the operating system used
# additional features like reading the MCN or ISRCs from the disc
# might be available. You can check for supported features with {has_feature?}.
#
# @see http://musicbrainz.org/doc/libdiscid#Feature_Matrix
#
# @example Read the TOC, MCN and ISRCs
#     require 'discid'
# 
#     device = "/dev/cdrom"
#     disc = DiscId.read(device, :mcn, :isrc)
# 
#     # Print information about the disc:
#     puts "DiscID      : #{disc.id}"
#     puts "FreeDB ID   : #{disc.freedb_id}"
#     puts "Total length: #{disc.seconds} seconds"
#     puts "MCN         : #{disc.mcn}"
#
#     # Print information about individual tracks:
#     disc.tracks do |track|
#       puts "Track ##{track.number}"
#       puts "  Length: %02d:%02d (%i sectors)" %
#           [track.seconds / 60, track.seconds % 60, track.sectors]
#       puts "  ISRC  : %s" % track.isrc
#     end
#
# @example Get the DiscID for an existing TOC
#     require 'discid'
#
#     first_track = 1
#     sectors = 82255
#     offsets = [150, 16157, 35932, 57527]
#     disc = DiscId.put(first_track, sectors, offsets)
#     puts disc.id # Output: E5VLOkhodzhvsMlK8LSNVioYOgY-
#
# @example Check for supported MCN feature
#     disc = DiscId.read(nil, :mcn)
#     puts "MCN: #{disc.mcn}" if DiscId.has_feature?(:mcn)
module DiscId

  # Read the disc in the given CD-ROM/DVD-ROM drive extracting only the
  # TOC and additionally specified features.
  #
  # This function reads the disc in the drive specified by the given device
  # identifier. If the device is `nil`, the default device, as returned by
  # {default_device}, is used.
  #
  # This function will always read the TOC, but additional features like `:mcn`
  # and `:isrc` can be set using the features parameter. You can set multiple
  # features.
  # 
  # @example Read only the TOC:
  #     disc = DiscId.read(device)
  #
  # @example Read the TOC, MCN and ISRCs:
  #     disc = DiscId.read(device, :mcn, :isrc)
  #
  # @note libdiscid >= 0.5.0 is required for the feature selection to work.
  #       Older versions will allways read MCN and ISRCs when supported. See
  #       {http://musicbrainz.org/doc/libdiscid#Feature_Matrix} for a list of
  #       supported features by version and platform.
  #
  # @raise [TypeError] `device` can not be converted to a String.
  # @raise [DiscError] Error reading from `device`. `Exception#message` contains
  #    error details.
  # @param device [String] The device identifier. If set to `nil` {default_device}
  #     will be used.
  # @param features [:mcn, :isrc] List of features to use.
  #     `:read` is always implied.
  # @return [Disc]
  def self.read(device = nil, *features)
    disc = Disc.new
    disc.read device, *features
    return disc
  end
    
  # Provides the TOC of a known CD.
  #
  # This function may be used if the TOC has been read earlier and you want to
  # calculate the disc ID afterwards, without accessing the disc drive. 
  #
  # @raise [DiscError] The TOC could not be set. `Exception#message`contains
  #    error details.
  # @param first_track [Integer] The number of the first audio track on the
  #   disc (usually one).
  # @param sectors [Integer] The total number of sectors on the disc.
  # @param offsets [Array] An array with track offsets (sectors) for each track.
  # @return [Disc]
  def self.put(first_track, sectors, offsets)
    disc = Disc.new
    disc.put first_track, sectors, offsets
    return disc
  end
    
  # Return the name of the default disc drive for this operating system.
  #
  # @return [String] An operating system dependent device identifier
  def self.default_device
    Lib.default_device
  end

  # Check if a certain feature is implemented on the current platform.
  #
  # You can obtain a list of supported features with {feature_list}.
  #
  # @note libdiscid >= 0.5.0 required. Older versions will return `true`
  #     for `:read` and `false` for anything else.
  #
  # @param feature [:read, :mcn, :isrc]
  # @return [Boolean] True if the feature is implemented and false if not.
  def self.has_feature?(feature)
    feature = feature.to_sym if feature.respond_to? :to_sym
    return self.feature_list.include? feature
  end

  # A list of features supported by the current platform.
  # 
  # Currently the following features are available:
  # 
  # * :read
  # * :mcn
  # * :isrc
  #
  # @note libdiscid >= 0.5.0 required. Older versions will return only [:read].
  #
  # @return [Array<Symbol>]
  def self.feature_list
    return Lib::Features.symbols.select {|f| Lib.has_feature(f) == 1}
  end

  # Converts sectors to seconds.
  # 
  # According to the red book standard 75 sectors are one second.
  #
  # @private
  # @param sectors [Integer] Number of sectors
  # @return [Integer] The seconds
  def self.sectors_to_seconds(sectors)
    return (sectors.to_f / 75).round
  end

  # The libdiscid version.
  #
  # @note This will only give meaningful results for libdiscid 0.4.0
  #  and higher. For lower versions this constant  will always have
  #  the value "libdiscid < 0.4.0".
  LIBDISCID_VERSION = Lib.get_version_string

end
