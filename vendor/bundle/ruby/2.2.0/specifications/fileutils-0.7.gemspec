# -*- encoding: utf-8 -*-
# stub: fileutils 0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "fileutils"
  s.version = "0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Stefaan Colman"]
  s.date = "2011-02-15"
  s.description = "A set of utility classes to extract meta data from different file types"
  s.rubygems_version = "2.4.8"
  s.summary = "Extracting meta data from file"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rmagick>, [">= 2.13.1"])
    else
      s.add_dependency(%q<rmagick>, [">= 2.13.1"])
    end
  else
    s.add_dependency(%q<rmagick>, [">= 2.13.1"])
  end
end
