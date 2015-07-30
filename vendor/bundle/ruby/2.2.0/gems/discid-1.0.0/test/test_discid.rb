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

require 'test/unit'
require 'discid'

# Helper class which can't be converted into a string.
class NotAString
  
  private
  
  def to_s
  end

end

# Unit test for the DiscId module.
class TestDiscId < Test::Unit::TestCase

  def setup
    @fiction_disc_id     = 'Wn8eRBtfLDfM0qjYPdxrz.Zjs_U-'
    @fiction_first_track = 1
    @fiction_last_track  = 10
    @fiction_sectors     = 206535
    @fiction_seconds     = 2754
    @fiction_offsets     = [150, 18901, 39738, 59557, 79152, 100126,
                            124833, 147278, 166336, 182560]
    @fiction_lengths     = [18751, 20837, 19819, 19595, 20974,
                            24707, 22445, 19058, 16224, 23975]
  end

  def teardown
  end
  
  # Test reading the disc id from a device.
  # We would need some kind of small test data to do this.
  #def test_read
  #  assert false, "Not implemented yet"
  #end
  
  # Test how read reacts on different arguments.
  # Those reads should all fail, but they must never cause a segmentation fault.
  def test_read_invalid_arguments
    assert_raise(TypeError) {DiscId.read(NotAString.new)}
    assert_raise(DiscId::DiscError) {DiscId.read(1)}
    assert_raise(DiscId::DiscError) {DiscId.read('invalid_device')}
    assert_raise(DiscId::DiscError) {DiscId.read(:invalid_device)}
  end
  
  def test_put_first_track_not_one
    disc = DiscId.put(3, @fiction_sectors,
                      @fiction_offsets)
    assert_equal 3, disc.first_track_number
    assert_equal 12, disc.last_track_number
    assert_equal 10, disc.tracks.size
  end
  
  # Test the tracks method and TrackInfo objects
  def test_put_and_tracks
    disc = nil
    
    assert_nothing_raised do
      disc = DiscId.put(@fiction_first_track, @fiction_sectors,
                        @fiction_offsets)
    end
    
    # Save a block for testing each track
    number = 0
    proc_test_track = lambda do |track|
      assert_equal number + 1, track.number
      
      assert_equal @fiction_offsets[number], track.offset
      assert_equal @fiction_lengths[number], track.sectors
      assert_equal @fiction_offsets[number]+ @fiction_lengths[number],
                   track.end_sector
                   
      assert_equal(DiscId.sectors_to_seconds(@fiction_offsets[number]),
                   track.start_time)
      assert_equal(DiscId.sectors_to_seconds(@fiction_lengths[number]),
                   track.seconds)
      assert_equal(DiscId.sectors_to_seconds(
                   @fiction_offsets[number]+ @fiction_lengths[number]),
                   track.end_time)
      
      number += 1
    end
    
    # Call track_info and retrieve an Array
    track_info = []                               
    assert_nothing_raised {track_info = disc.tracks}
    assert track_info.is_a?(Array)
    track_info.each(&proc_test_track)
    assert_equal disc.last_track_number, number
    
    # Calling track_info directly with a given block
    # Reset the number of tracks (the above block is a closure, so this works)
    number = 0
    assert_equal nil, disc.tracks(&proc_test_track)
    assert_equal disc.last_track_number, number
  end
  
  # Test the conversion from sectors to seconds
  def test_sectors_to_seconds
    assert_equal 0, DiscId.sectors_to_seconds(0)
    assert_equal @fiction_seconds,
                 DiscId.sectors_to_seconds(@fiction_sectors)
  end

  def test_has_feature
    assert(DiscId.has_feature?(:read),
           "Feature :read should be supported")
    assert(DiscId.has_feature?("read"),
           "Feature 'read' should be supported")
    assert(!DiscId.has_feature?(:notafeature),
           "Feature :notafeature should not be supported")
    assert(!DiscId.has_feature?("notafeature"),
           "Feature 'notafeature' should not be supported")
  end
  
  def test_feature_list_must_contain_read
    assert(DiscId.feature_list.include?(:read),
           "Feature :read should be supported")
  end

  def test_libdiscid_version_should_start_with_libdiscid
    version = DiscId::LIBDISCID_VERSION
    assert version.kind_of?(String)
    assert version.start_with?("libdiscid")
  end

  def test_default_device_is_a_string
    device = DiscId.default_device
    assert device.kind_of?(String)
  end

end
