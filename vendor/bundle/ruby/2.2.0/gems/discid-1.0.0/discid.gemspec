# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'discid/version'

Gem::Specification.new do |spec|
  spec.name          = "discid"
  spec.version       = DiscId::VERSION
  spec.authors       = ["Philipp Wolfer"]
  spec.email         = ["ph.wolfer@gmail.com"]
  spec.description   = %q{ruby-discid provides Ruby bindings for the MusicBrainz DiscID library libdiscid. It allows calculating DiscIDs (MusicBrainz and freedb) for Audio CDs. Additionally the library can extract the MCN/UPC/EAN and the ISRCs from disc.}
  spec.summary       = %q{Ruby bindings for libdiscid}
  spec.homepage      = "https://github.com/phw/ruby-discid"
  spec.license       = "LGPL-3"
  spec.post_install_message = %q{Please make sure you have libdiscid (http://musicbrainz.org/doc/libdiscid) installed.}

  spec.requirements              = "libdiscid >= 0.1.0"
  spec.required_ruby_version     = ">= 1.8.7"
  spec.required_rubygems_version = ">= 1.3.6"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", ">= 1.6.0"

  spec.add_development_dependency "bundler", ">= 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "kramdown"
end
