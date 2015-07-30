# -*- encoding: utf-8 -*-
# stub: discid 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "discid"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Philipp Wolfer"]
  s.date = "2013-05-01"
  s.description = "ruby-discid provides Ruby bindings for the MusicBrainz DiscID library libdiscid. It allows calculating DiscIDs (MusicBrainz and freedb) for Audio CDs. Additionally the library can extract the MCN/UPC/EAN and the ISRCs from disc."
  s.email = ["ph.wolfer@gmail.com"]
  s.homepage = "https://github.com/phw/ruby-discid"
  s.licenses = ["LGPL-3"]
  s.post_install_message = "Please make sure you have libdiscid (http://musicbrainz.org/doc/libdiscid) installed."
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.requirements = ["libdiscid >= 0.1.0"]
  s.rubygems_version = "2.4.8"
  s.summary = "Ruby bindings for libdiscid"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, [">= 1.6.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<kramdown>, [">= 0"])
    else
      s.add_dependency(%q<ffi>, [">= 1.6.0"])
      s.add_dependency(%q<bundler>, [">= 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<kramdown>, [">= 0"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 1.6.0"])
    s.add_dependency(%q<bundler>, [">= 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<kramdown>, [">= 0"])
  end
end
