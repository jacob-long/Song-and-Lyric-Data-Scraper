# Ruby bindings for MusicBrainz libdiscid

## About
ruby-discid provides Ruby bindings for the MusicBrainz DiscID library libdiscid.
It allows calculating DiscIDs (MusicBrainz and freedb) for Audio CDs. Additionally
the library can extract the MCN/UPC/EAN and the ISRCs from disc.

## Requirements
* Ruby >= 1.8.7
* RubyGems >= 1.3.6
* Ruby-FFI >= 1.6.0
* libdiscid >= 0.1.0

## Installation
Before installing ruby-discid make sure you have libdiscid installed. See
http://musicbrainz.org/doc/libdiscid for more information on how to do this.

Installing ruby-discid is best done using RubyGems:

    gem install discid

You can also install from source. This requires RubyGems and Bundler installed.
First make sure you have installed bundler:

    gem install bundler

Then inside the ruby-discid source directory run:
    
    bundle install
    rake install

`bundle install` will install additional development dependencies (Rake, Yard
and Kramdown). `rake install` will build the discid gem and install it.
 
## Usage

### Read only the TOC

    require 'discid'

    device = "/dev/cdrom"
    disc = DiscId.read(device)
    puts disc.id

### Read the TOC, MCN and ISRCs

    require 'discid'
    
    device = "/dev/cdrom"
    disc = DiscId.read(device, :mcn, :isrc)
    
    # Print information about the disc:
    puts "DiscID      : #{disc.id}"
    puts "FreeDB ID   : #{disc.freedb_id}"
    puts "Total length: #{disc.seconds} seconds"
    puts "MCN         : #{disc.mcn}"

    # Print information about individual tracks:
    disc.tracks do |track|
      puts "Track ##{track.number}"
      puts "  Length: %02d:%02d (%i sectors)" %
          [track.seconds / 60, track.seconds % 60, track.sectors]
      puts "  ISRC  : %s" % track.isrc
    end

See the [API documentation](http://rubydoc.info/github/phw/ruby-discid/master/frames)
of {DiscId} or the files in the `examples` directory for more usage information.

## Contribute
The source code for ruby-discid is available on
[GitHub](https://github.com/phw/ruby-discid).

Please report any issues on the
[issue tracker](https://github.com/phw/ruby-discid/issues).

## License
ruby-discid is released under the GNU Lesser General Public License Version 3.
See LICENSE for details.