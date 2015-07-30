# -*- encoding: utf-8 -*-
# stub: discogs-wrapper 2.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "discogs-wrapper"
  s.version = "2.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Andrew Buntine", "Many more contributors"]
  s.date = "2015-01-07"
  s.description = "Discogs::Wrapper is a full wrapper for the http://www.discogs.com API V2. Supports authentication, pagination, JSON."
  s.email = "info@andrewbuntine.com"
  s.homepage = "http://www.github.com/buntine/discogs"
  s.rubygems_version = "2.4.8"
  s.summary = "Discogs::Wrapper is a full wrapper for the http://www.discogs.com API V2"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<pry-nav>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["= 2.12.0"])
      s.add_development_dependency(%q<simplecov>, ["= 0.7.1"])
      s.add_runtime_dependency(%q<hashie>, ["~> 2.1"])
      s.add_runtime_dependency(%q<oauth>, ["~> 0.4.7"])
    else
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<pry-nav>, [">= 0"])
      s.add_dependency(%q<rspec>, ["= 2.12.0"])
      s.add_dependency(%q<simplecov>, ["= 0.7.1"])
      s.add_dependency(%q<hashie>, ["~> 2.1"])
      s.add_dependency(%q<oauth>, ["~> 0.4.7"])
    end
  else
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<pry-nav>, [">= 0"])
    s.add_dependency(%q<rspec>, ["= 2.12.0"])
    s.add_dependency(%q<simplecov>, ["= 0.7.1"])
    s.add_dependency(%q<hashie>, ["~> 2.1"])
    s.add_dependency(%q<oauth>, ["~> 0.4.7"])
  end
end
