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

require "ffi"

module DiscId

  # This module encapsulates the C interface for libdiscid using FFI.
  # The Lib module is intended for internal use only and should be
  # considered private.
  #
  # @private
  module Lib
    extend FFI::Library
    ffi_lib %w[discid libdiscid.so.0 libdiscid.0.dylib]

    attach_function :new, :discid_new, [], :pointer

    attach_function :free, :discid_free, [:pointer], :void
  
    begin
      attach_function :read, :discid_read_sparse, [:pointer, :string, :uint], :int
    rescue FFI::NotFoundError
      attach_function :legacy_read, :discid_read, [:pointer, :string], :int
      
      def self.read(handle, device, features)
        legacy_read(handle, device)
      end
    end

    attach_function :put, :discid_put, [:pointer, :int, :int, :pointer], :int

    attach_function :get_error_msg, :discid_get_error_msg, [:pointer], :string
    
    attach_function :get_id, :discid_get_id, [:pointer], :string

    attach_function :get_freedb_id, :discid_get_freedb_id, [:pointer], :string

    attach_function :get_submission_url, :discid_get_submission_url, [:pointer], :string
    
    attach_function :default_device, :discid_get_default_device, [], :string

    attach_function :get_first_track_num, :discid_get_first_track_num, [:pointer], :int

    attach_function :get_last_track_num, :discid_get_last_track_num, [:pointer], :int

    attach_function :get_sectors, :discid_get_sectors, [:pointer], :int

    attach_function :get_track_offset, :discid_get_track_offset, [:pointer, :int], :int

    attach_function :get_track_length, :discid_get_track_length, [:pointer, :int], :int

    begin
      attach_function :get_mcn, :discid_get_mcn, [:pointer], :string
    rescue FFI::NotFoundError
      def self.get_mcn(handle)
        return nil
      end
    end

    begin
      attach_function :get_track_isrc, :discid_get_track_isrc, [:pointer, :int], :string
    rescue FFI::NotFoundError
      def self.get_track_isrc(handle, track)
        return nil
      end
    end

    Features = enum(:feature, [:read, 1 << 0,
                               :mcn, 1 << 1,
                               :isrc, 1 << 2])

    begin
      attach_function :has_feature, :discid_has_feature, [:feature], :int
    rescue FFI::NotFoundError
      def self.has_feature(feature)
        return feature.to_sym == :read ? 1 : 0
      end
    end

    #attach_function :get_feature_list, :discid_get_feature_list, [:pointer], :void
    
    begin
      attach_function :get_version_string, :discid_get_version_string, [], :string
    rescue FFI::NotFoundError
      def self.get_version_string
        return "libdiscid < 0.4.0"
      end
    end

    def self.features_to_int(features)
      feature_flag = 0
      features.each do |feature|
        if feature.respond_to? :to_sym
          feature = feature.to_sym
          feature_flag |= self::Features[feature] if
            self::Features.symbols.include?(feature) and
            self.has_feature(feature)
        end
      end

      return feature_flag
    end
  end
end
