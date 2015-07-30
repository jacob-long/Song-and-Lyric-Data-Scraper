require_relative '../../spec_helper.rb'
require 'ox'
require 'rr'

module UnderFire
  describe AlbumSearch do
    subject {AlbumSearch.new(mode: "SINGLE_BEST_COVER",
                             artist: "Radiohead",
                             track_title: "Paranoid Android",
                             album_title: "OK Computer")}

    before do
      ENV['UF_CONFIG_PATH'] = File.expand_path('spec/fixtures/.ufrc')
    end

    it "accepts a hash of arguments" do
      subject.artist.must_equal "Radiohead"
      subject.track_title.must_equal "Paranoid Android"
    end

    describe "#query" do
      it "returns well formed xml" do
        Ox.load(subject.query).must_be_kind_of Ox::Element
      end

      it "returns xml with an auth element" do
        subject.query.must_include "<AUTH>"
        subject.query.must_include "</AUTH>"
      end

      describe "with all fields" do
        it "returns the correct xml query" do
          subject.query.must_include "Radiohead"
        end
      end

      describe "with artist" do
        subject{AlbumSearch.new(artist: "Radiohead")}
        it "returns an xml query with an artist name" do
          subject.query.must_include "Radiohead"
        end

        it "does not return album_title or track_title fields" do
          subject.query.wont_include "TRACK_TITLE"
          subject.query.wont_include "ALBUM_TITLE"
        end
      end
    end
  end
end
