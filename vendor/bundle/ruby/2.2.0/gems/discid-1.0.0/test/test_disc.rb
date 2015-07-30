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

# Unit test for the DiscId::Disc class.
class TestDisc < Test::Unit::TestCase
  
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
  
  def test_empty_disc
    disc = DiscId::Disc.new
    assert_equal nil, disc.id
    assert_equal nil, disc.freedb_id
    assert_equal '', disc.to_s
    assert_equal nil, disc.first_track_number
    assert_equal nil, disc.last_track_number
    assert_equal nil, disc.sectors
    assert_equal nil, disc.seconds
    assert_equal nil, disc.tracks
    assert_equal nil, disc.device
    assert_equal nil, disc.submission_url
    assert_equal nil, disc.mcn
    assert_equal nil, disc.device
  end

  # Test calculation of the disc id if the TOC information
  # gets set by the put method.
  # All attributes should be nil after a failure, even if there was a
  # successfull put before.
  def test_put
    disc = DiscId::Disc.new
    
    # Erroneous put
    assert_raise(DiscId::DiscError) do
      disc = DiscId.put(-1, @fiction_sectors, @fiction_offsets)
    end
    assert_equal nil, disc.id
    assert_equal '', disc.to_s
    assert_equal nil, disc.first_track_number
    assert_equal nil, disc.last_track_number
    assert_equal nil, disc.sectors
    assert_equal nil, disc.seconds
    assert_equal nil, disc.tracks
    
    # Second successfull put
    assert_nothing_raised do
      disc = DiscId.put(@fiction_first_track, @fiction_sectors,
                        @fiction_offsets)
    end
    assert_equal @fiction_disc_id, disc.id
    assert_equal @fiction_disc_id, disc.to_s
    assert_equal @fiction_first_track, disc.first_track_number
    assert_equal @fiction_last_track, disc.last_track_number
    assert_equal @fiction_sectors, disc.sectors
    assert_equal @fiction_seconds, disc.seconds
    assert_equal @fiction_offsets, disc.tracks.map{|t| t.offset}
    assert_equal @fiction_lengths, disc.tracks.map{|t| t.sectors}
  end

end
