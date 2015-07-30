# -*- encoding: utf-8 -*-
# stub: echowrap 0.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "echowrap"
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tim Case"]
  s.date = "2014-07-03"
  s.description = "A Ruby interface to the Echonest API, details can be found at http://echowrap.com."
  s.email = ["tim@2drops.net"]
  s.homepage = "https://github.com/timcase/echowrap"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A Ruby interface to the Echonest API."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.9"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_runtime_dependency(%q<simple_oauth>, ["~> 0.2"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.9"])
      s.add_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_dependency(%q<simple_oauth>, ["~> 0.2"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.9"])
    s.add_dependency(%q<multi_json>, ["~> 1.0"])
    s.add_dependency(%q<simple_oauth>, ["~> 0.2"])
  end
end
