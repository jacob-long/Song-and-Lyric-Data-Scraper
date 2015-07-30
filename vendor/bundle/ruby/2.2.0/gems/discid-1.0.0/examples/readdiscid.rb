#!/usr/bin/env ruby
#
# Example script for DiscId.
# 
# This script will read the disc ID from the default device and print
# the results. You can specify an alternate device to use by giving the
# device's name as the first command line argument.
# 
# Example:
#  ./discid.rb /dev/dvd

# Just make sure we can run this example from the command
# line even if DiscId is not yet installed properly.
$: << 'lib/' << 'ext/' << '../ext/' << '../lib/'

require 'discid'

# Read the device name from the command line or use the default.
device = $*[0] ? $*[0] : DiscId.default_device

# Create a new DiscID object and read the disc information.
# In case of errors exit the application.
puts "Reading TOC from device '#{device}'."
begin
  disc = DiscId.read(device, :isrc, :mcn)
  
  # Instead of reading from a device we could set the TOC directly:
  #disc = DiscId.put(1, 82255, [150, 16157, 35932, 57527])
rescue DiscId::DiscError => e
  puts e
  exit(1)
end

# Print information about the disc:
print <<EOF

Device      : #{disc.device}
DiscID      : #{disc.id}
FreeDB ID   : #{disc.freedb_id}
First track : #{disc.last_track_number}
Last track  : #{disc.first_track_number}
Total length: #{disc.seconds} seconds
Sectors     : #{disc.sectors}
EOF

puts "MCN         : #{disc.mcn}" if DiscId.has_feature?(:mcn)
puts

# Print information about individual tracks:
disc.tracks do |track|
  puts "Track ##{track.number}"
  puts "  Length: %02d:%02d (%i sectors)" %
      [track.seconds / 60, track.seconds % 60, track.sectors]
  puts "  Start : %02d:%02d (sector %i)" %
      [track.start_time / 60, track.start_time % 60, track.offset]
  puts "  End   : %02d:%02d (sector %i)" %
      [track.end_time / 60, track.end_time % 60, track.end_sector]
  puts "  ISRC  : %s" % track.isrc if DiscId.has_feature?(:isrc)
end

# Print a submission URL that can be used to submit
# the disc ID to MusicBrainz.org.
puts "\nSubmit via #{disc.submission_url}"
