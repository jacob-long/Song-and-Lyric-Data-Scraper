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

# Print information about libdiscid
print <<EOF
Version           : #{DiscId::LIBDISCID_VERSION}
Default device    : #{DiscId.default_device}
Supported features: #{DiscId.feature_list.join(', ')}
EOF
