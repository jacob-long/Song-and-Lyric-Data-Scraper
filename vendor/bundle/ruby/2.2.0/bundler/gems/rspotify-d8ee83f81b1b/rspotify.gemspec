# -*- encoding: utf-8 -*-
# stub: rspotify 1.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rspotify"
  s.version = "1.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Guilherme Sad"]
  s.date = "2015-07-05"
  s.email = ["gorgulhoguilherme@gmail.com"]
  s.files = [".editorconfig", ".gitignore", ".rspec", ".travis.yml", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "lib/rspotify.rb", "lib/rspotify/album.rb", "lib/rspotify/artist.rb", "lib/rspotify/base.rb", "lib/rspotify/category.rb", "lib/rspotify/connection.rb", "lib/rspotify/oauth.rb", "lib/rspotify/playlist.rb", "lib/rspotify/track.rb", "lib/rspotify/user.rb", "lib/rspotify/version.rb", "rspotify.gemspec", "spec/lib/rspotify/album_spec.rb", "spec/lib/rspotify/artist_spec.rb", "spec/lib/rspotify/category_spec.rb", "spec/lib/rspotify/playlist_spec.rb", "spec/lib/rspotify/track_spec.rb", "spec/lib/rspotify/user_spec.rb", "spec/lib/rspotify_spec.rb", "spec/spec_helper.rb", "spec/vcr_cassettes/album_find_2agWNCZl5Ts9W05mij8EPh.yml", "spec/vcr_cassettes/album_find_3JquYMWj5wrzuZCNAvOYN9.yml", "spec/vcr_cassettes/album_find_5bU1XKYxHhEwukllT20xtk.yml", "spec/vcr_cassettes/album_new_releases.yml", "spec/vcr_cassettes/album_new_releases_country_ES.yml", "spec/vcr_cassettes/album_new_releases_limit_10_offset_10.yml", "spec/vcr_cassettes/album_search_AM.yml", "spec/vcr_cassettes/album_search_AM_limit_10.yml", "spec/vcr_cassettes/album_search_AM_market_ES.yml", "spec/vcr_cassettes/album_search_AM_offset_10.yml", "spec/vcr_cassettes/album_search_AM_offset_10_limit_10.yml", "spec/vcr_cassettes/artist_7Ln80lUS6He07XvHI8qqHH_albums_limit_20_offset_0.yml", "spec/vcr_cassettes/artist_7Ln80lUS6He07XvHI8qqHH_related_artists.yml", "spec/vcr_cassettes/artist_7Ln80lUS6He07XvHI8qqHH_top_tracks_US.yml", "spec/vcr_cassettes/artist_find_0oSGxfWSnnOXhD2fKuz2Gy.yml", "spec/vcr_cassettes/artist_find_3dBVyJ7JuOMt4GE9607Qin.yml", "spec/vcr_cassettes/artist_find_7Ln80lUS6He07XvHI8qqHH.yml", "spec/vcr_cassettes/artist_search_Arctic.yml", "spec/vcr_cassettes/artist_search_Arctic_limit_10.yml", "spec/vcr_cassettes/artist_search_Arctic_market_ES.yml", "spec/vcr_cassettes/artist_search_Arctic_offset_10.yml", "spec/vcr_cassettes/artist_search_Arctic_offset_10_limit_10.yml", "spec/vcr_cassettes/authenticate_client.yml", "spec/vcr_cassettes/category_find_party.yml", "spec/vcr_cassettes/category_find_party_country_BR.yml", "spec/vcr_cassettes/category_find_party_locale_es_MX.yml", "spec/vcr_cassettes/category_list.yml", "spec/vcr_cassettes/category_list_country_BR.yml", "spec/vcr_cassettes/category_list_locale_es_MX_limit_10.yml", "spec/vcr_cassettes/category_party_playlists.yml", "spec/vcr_cassettes/category_party_playlists_country_BR.yml", "spec/vcr_cassettes/category_party_playlists_limit_10_offset_20.yml", "spec/vcr_cassettes/playlist_browse_featured.yml", "spec/vcr_cassettes/playlist_browse_featured_country_ES_timestamp_2014-10-23T09_00_00.yml", "spec/vcr_cassettes/playlist_browse_featured_limit_10_offset_10.yml", "spec/vcr_cassettes/playlist_browse_featured_locale_es_MX.yml", "spec/vcr_cassettes/playlist_find_118430647_starred.yml", "spec/vcr_cassettes/playlist_find_spotify_4LO89Y0ydu8li9Phq2iwKT.yml", "spec/vcr_cassettes/playlist_find_wizzler_00wHcTN0zQiun4xri9pmvX.yml", "spec/vcr_cassettes/playlist_is_followed_by.yml", "spec/vcr_cassettes/playlist_search_Indie.yml", "spec/vcr_cassettes/playlist_search_Indie_limit_10.yml", "spec/vcr_cassettes/playlist_search_Indie_offset_10.yml", "spec/vcr_cassettes/playlist_search_Indie_offset_10_limit_10.yml", "spec/vcr_cassettes/playlist_tracks_118430647_starred.yml", "spec/vcr_cassettes/track_find_3jfr0TF6DQcOLat8gGn7E2.yml", "spec/vcr_cassettes/track_find_4oI9kesyxHUr8fqiLd6uO9.yml", "spec/vcr_cassettes/track_find_7D8BAYkrR9peCB9XSKCADc.yml", "spec/vcr_cassettes/track_search_Wanna_Know.yml", "spec/vcr_cassettes/track_search_Wanna_Know_limit_10.yml", "spec/vcr_cassettes/track_search_Wanna_Know_limit_10_offset_10.yml", "spec/vcr_cassettes/track_search_Wanna_Know_market_ES.yml", "spec/vcr_cassettes/track_search_Wanna_Know_offset_10.yml", "spec/vcr_cassettes/user_find_spotify.yml", "spec/vcr_cassettes/user_find_wizzler.yml", "spec/vcr_cassettes/user_wizzler_playlists_limit_20_offset_0.yml"]
  s.homepage = "http://rubygems.org/gems/rspotify"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.4.8"
  s.summary = "A ruby wrapper for the Spotify Web API"
  s.test_files = ["spec/lib/rspotify/album_spec.rb", "spec/lib/rspotify/artist_spec.rb", "spec/lib/rspotify/category_spec.rb", "spec/lib/rspotify/playlist_spec.rb", "spec/lib/rspotify/track_spec.rb", "spec/lib/rspotify/user_spec.rb", "spec/lib/rspotify_spec.rb", "spec/spec_helper.rb", "spec/vcr_cassettes/album_find_2agWNCZl5Ts9W05mij8EPh.yml", "spec/vcr_cassettes/album_find_3JquYMWj5wrzuZCNAvOYN9.yml", "spec/vcr_cassettes/album_find_5bU1XKYxHhEwukllT20xtk.yml", "spec/vcr_cassettes/album_new_releases.yml", "spec/vcr_cassettes/album_new_releases_country_ES.yml", "spec/vcr_cassettes/album_new_releases_limit_10_offset_10.yml", "spec/vcr_cassettes/album_search_AM.yml", "spec/vcr_cassettes/album_search_AM_limit_10.yml", "spec/vcr_cassettes/album_search_AM_market_ES.yml", "spec/vcr_cassettes/album_search_AM_offset_10.yml", "spec/vcr_cassettes/album_search_AM_offset_10_limit_10.yml", "spec/vcr_cassettes/artist_7Ln80lUS6He07XvHI8qqHH_albums_limit_20_offset_0.yml", "spec/vcr_cassettes/artist_7Ln80lUS6He07XvHI8qqHH_related_artists.yml", "spec/vcr_cassettes/artist_7Ln80lUS6He07XvHI8qqHH_top_tracks_US.yml", "spec/vcr_cassettes/artist_find_0oSGxfWSnnOXhD2fKuz2Gy.yml", "spec/vcr_cassettes/artist_find_3dBVyJ7JuOMt4GE9607Qin.yml", "spec/vcr_cassettes/artist_find_7Ln80lUS6He07XvHI8qqHH.yml", "spec/vcr_cassettes/artist_search_Arctic.yml", "spec/vcr_cassettes/artist_search_Arctic_limit_10.yml", "spec/vcr_cassettes/artist_search_Arctic_market_ES.yml", "spec/vcr_cassettes/artist_search_Arctic_offset_10.yml", "spec/vcr_cassettes/artist_search_Arctic_offset_10_limit_10.yml", "spec/vcr_cassettes/authenticate_client.yml", "spec/vcr_cassettes/category_find_party.yml", "spec/vcr_cassettes/category_find_party_country_BR.yml", "spec/vcr_cassettes/category_find_party_locale_es_MX.yml", "spec/vcr_cassettes/category_list.yml", "spec/vcr_cassettes/category_list_country_BR.yml", "spec/vcr_cassettes/category_list_locale_es_MX_limit_10.yml", "spec/vcr_cassettes/category_party_playlists.yml", "spec/vcr_cassettes/category_party_playlists_country_BR.yml", "spec/vcr_cassettes/category_party_playlists_limit_10_offset_20.yml", "spec/vcr_cassettes/playlist_browse_featured.yml", "spec/vcr_cassettes/playlist_browse_featured_country_ES_timestamp_2014-10-23T09_00_00.yml", "spec/vcr_cassettes/playlist_browse_featured_limit_10_offset_10.yml", "spec/vcr_cassettes/playlist_browse_featured_locale_es_MX.yml", "spec/vcr_cassettes/playlist_find_118430647_starred.yml", "spec/vcr_cassettes/playlist_find_spotify_4LO89Y0ydu8li9Phq2iwKT.yml", "spec/vcr_cassettes/playlist_find_wizzler_00wHcTN0zQiun4xri9pmvX.yml", "spec/vcr_cassettes/playlist_is_followed_by.yml", "spec/vcr_cassettes/playlist_search_Indie.yml", "spec/vcr_cassettes/playlist_search_Indie_limit_10.yml", "spec/vcr_cassettes/playlist_search_Indie_offset_10.yml", "spec/vcr_cassettes/playlist_search_Indie_offset_10_limit_10.yml", "spec/vcr_cassettes/playlist_tracks_118430647_starred.yml", "spec/vcr_cassettes/track_find_3jfr0TF6DQcOLat8gGn7E2.yml", "spec/vcr_cassettes/track_find_4oI9kesyxHUr8fqiLd6uO9.yml", "spec/vcr_cassettes/track_find_7D8BAYkrR9peCB9XSKCADc.yml", "spec/vcr_cassettes/track_search_Wanna_Know.yml", "spec/vcr_cassettes/track_search_Wanna_Know_limit_10.yml", "spec/vcr_cassettes/track_search_Wanna_Know_limit_10_offset_10.yml", "spec/vcr_cassettes/track_search_Wanna_Know_market_ES.yml", "spec/vcr_cassettes/track_search_Wanna_Know_offset_10.yml", "spec/vcr_cassettes/user_find_spotify.yml", "spec/vcr_cassettes/user_find_wizzler.yml", "spec/vcr_cassettes/user_wizzler_playlists_limit_20_offset_0.yml"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth-oauth2>, ["~> 1.1"])
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.7"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<vcr>, ["~> 2.9"])
    else
      s.add_dependency(%q<omniauth-oauth2>, ["~> 1.1"])
      s.add_dependency(%q<rest-client>, ["~> 1.7"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<vcr>, ["~> 2.9"])
    end
  else
    s.add_dependency(%q<omniauth-oauth2>, ["~> 1.1"])
    s.add_dependency(%q<rest-client>, ["~> 1.7"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<vcr>, ["~> 2.9"])
  end
end
