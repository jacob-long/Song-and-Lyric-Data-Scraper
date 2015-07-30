# -*- encoding: utf-8 -*-
# stub: similar_text 0.0.4 ruby lib lib
# stub: ext/similar_text/extconf.rb

Gem::Specification.new do |s|
  s.name = "similar_text"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib", "lib"]
  s.authors = ["Arthur Murauskas"]
  s.date = "2011-09-24"
  s.description = "Port of PHP function similar_text to Ruby as a native extension. Adds methods similar and similar_chars to core String class."
  s.email = ["arthur.murauskas@gmail.com"]
  s.extensions = ["ext/similar_text/extconf.rb"]
  s.extra_rdoc_files = ["README.markdown", "CHANGELOG.rdoc"]
  s.files = ["CHANGELOG.rdoc", "README.markdown", "ext/similar_text/extconf.rb"]
  s.homepage = "http://github.com/valcker/similar_text-ruby"
  s.rdoc_options = ["-m", "README.markdown", "-x", "lib/similar_text/version.rb"]
  s.rubyforge_project = "similar_text"
  s.rubygems_version = "2.4.8"
  s.summary = "Port of PHP function similar_text to Ruby as a native extension. Adds methods similar and similar_chars to core String class."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version
end
