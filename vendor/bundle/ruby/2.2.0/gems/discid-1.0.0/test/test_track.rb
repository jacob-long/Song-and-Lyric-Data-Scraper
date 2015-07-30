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
require 'discid/track'

# Unit test for the DiscId::Track class.
class TestTrack < Test::Unit::TestCase

  def setup
    @number = 3
    @offset = 1035
    @length = 23643
    @isrc = "US4E40731510"
  end

  def test_init_track_info
    track = DiscId::Track.new @number, @offset, @length, @isrc

    assert_equal @number, track.number
    assert_equal @offset, track.offset
    assert_equal @length, track.sectors
    assert_equal @isrc, track.isrc

    assert_equal @offset + @length, track.end_sector
    assert_equal 315, track.seconds
    assert_equal 14, track.start_time
    assert_equal 329, track.end_time
  end

  def test_to_hash
    track = DiscId::Track.new @number, @offset, @length, @isrc
    hash = track.to_hash

    assert_equal track.number, hash[:number]
    assert_equal track.offset, hash[:offset]
    assert_equal track.sectors, hash[:sectors]
    assert_equal track.isrc, hash[:isrc]

    assert_equal track.end_sector, hash[:end_sector]
    assert_equal track.seconds, hash[:seconds]
    assert_equal track.start_time, hash[:start_time]
    assert_equal track.end_time, hash[:end_time]
  end

  def test_selector_access
    track = DiscId::Track.new @number, @offset, @length, @isrc
 
    assert_equal track.number, track[:number]
    assert_equal track.offset, track[:offset]
    assert_equal track.sectors, track[:sectors]
    assert_equal track.isrc, track[:isrc]

    assert_equal track.end_sector, track[:end_sector]
    assert_equal track.seconds, track[:seconds]
    assert_equal track.start_time, track[:start_time]
    assert_equal track.end_time, track[:end_time]
  end

  def test_invalid_selector_value
    track = DiscId::Track.new @number, @offset, @length, @isrc
    assert_equal nil, track[:invalid_value]
  end

end
