# -*- encoding: utf-8 -*-
# stub: lyricfy 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "lyricfy"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Javier Hidalgo"]
  s.date = "2015-07-05"
  s.description = "Song Lyrics for your Ruby apps"
  s.email = ["hola@soyjavierhidalgo.com"]
  s.executables = ["lyricfy"]
  s.files = [".gitignore", ".travis.yml", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "bin/lyricfy", "lib/lyricfy.rb", "lib/lyricfy/lyric_provider.rb", "lib/lyricfy/providers/metro_lyrics.rb", "lib/lyricfy/providers/wikia.rb", "lib/lyricfy/song.rb", "lib/lyricfy/uri_helper.rb", "lib/lyricfy/version.rb", "lyricfy.gemspec", "spec/fixtures/vcr_cassettes/metro_lyrics_200.yml", "spec/fixtures/vcr_cassettes/metro_lyrics_404.yml", "spec/fixtures/vcr_cassettes/wikia_200.yml", "spec/fixtures/vcr_cassettes/wikia_404.yml", "spec/lyricfy_spec.rb", "spec/providers/metro_lyrics_spec.rb", "spec/providers/wikia_spec.rb", "spec/song_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "https://github.com/javichito/lyricfy"
  s.rubygems_version = "2.4.8"
  s.summary = "Lyricfy lets you get song lyrics that you can use on your apps"
  s.test_files = ["spec/fixtures/vcr_cassettes/metro_lyrics_200.yml", "spec/fixtures/vcr_cassettes/metro_lyrics_404.yml", "spec/fixtures/vcr_cassettes/wikia_200.yml", "spec/fixtures/vcr_cassettes/wikia_404.yml", "spec/lyricfy_spec.rb", "spec/providers/metro_lyrics_spec.rb", "spec/providers/wikia_spec.rb", "spec/song_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<webmock>, ["= 1.8.0"])
      s.add_development_dependency(%q<vcr>, ["~> 2.4.0"])
    else
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<webmock>, ["= 1.8.0"])
      s.add_dependency(%q<vcr>, ["~> 2.4.0"])
    end
  else
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<webmock>, ["= 1.8.0"])
    s.add_dependency(%q<vcr>, ["~> 2.4.0"])
  end
end
