require_relative '../../spec_helper'
require 'under_fire/album_fetch'
require 'ox'

module UnderFire
  describe AlbumFetch do
    subject {AlbumFetch.new(:gn_id => '7F28ADC369EB90E53A7F6CA3A70D56V')}

    before do
      ENV['UF_CONFIG_PATH'] = File.expand_path('spec/fixtures/.ufrc')
      @config = UnderFire::Configuration.instance
    end

    describe "instantiation" do
      it "accepts an album GN_ID as input" do
        AlbumFetch.new(:gn_id => '7F28ADC369EB90E53A7F6CA3A70D56V').must_be_kind_of UnderFire::AlbumFetch
      end
    end

    describe "#query" do

      it "returns properly formed xml" do
        #`Ox.load` returns Ox::ParseError if xml is malformed
        Ox.load(subject.query).must_be_kind_of Ox::Element
      end

      it "returns the correct xml query" do
        subject.query.must_include "GN_ID"
        subject.query.must_include "ALBUM_FETCH"
        subject.query.must_include "7F28ADC369EB90E53A7F6CA3A70D56V"
      end
    end
  end
end
