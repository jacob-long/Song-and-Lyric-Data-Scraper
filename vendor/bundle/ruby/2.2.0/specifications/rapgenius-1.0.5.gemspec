# -*- encoding: utf-8 -*-
# stub: rapgenius 1.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "rapgenius"
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tim Rogers"]
  s.date = "2015-01-12"
  s.description = "Up until until now, to quote RapGenius themselves,\n    \"working at Rap Genius is the API\". With this magical gem using the\n    private API in the 'Genius' iOS app you can access the wealth of data on\n    the internet Talmud in Ruby."
  s.email = ["me@timrogers.co.uk"]
  s.homepage = "https://github.com/timrogers/rapgenius"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A gem for accessing lyrics and explanations on RapGenius.com"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, ["~> 0.11.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14.1"])
      s.add_development_dependency(%q<mocha>, ["~> 0.14.0"])
      s.add_development_dependency(%q<webmock>, ["~> 1.11.0"])
      s.add_development_dependency(%q<vcr>, ["~> 2.5.0"])
    else
      s.add_dependency(%q<httparty>, ["~> 0.11.0"])
      s.add_dependency(%q<rspec>, ["~> 2.14.1"])
      s.add_dependency(%q<mocha>, ["~> 0.14.0"])
      s.add_dependency(%q<webmock>, ["~> 1.11.0"])
      s.add_dependency(%q<vcr>, ["~> 2.5.0"])
    end
  else
    s.add_dependency(%q<httparty>, ["~> 0.11.0"])
    s.add_dependency(%q<rspec>, ["~> 2.14.1"])
    s.add_dependency(%q<mocha>, ["~> 0.14.0"])
    s.add_dependency(%q<webmock>, ["~> 1.11.0"])
    s.add_dependency(%q<vcr>, ["~> 2.5.0"])
  end
end
