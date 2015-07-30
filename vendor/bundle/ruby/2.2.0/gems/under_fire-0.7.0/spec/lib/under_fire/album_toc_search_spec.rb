require_relative '../../spec_helper.rb'
require 'rr'
require 'ox'

module UnderFire
  describe AlbumTOCSearch do
    let(:toc){"182 10762 22515 32372 43735 53335 63867 78305 89792 98702 "+
        "110612 122590 132127 141685"}
    subject {AlbumTOCSearch.new(toc: toc)}

    before do
      ENV['UF_CONFIG_PATH'] = File.expand_path('spec/fixtures/.ufrc')
      @config = UnderFire::Configuration.instance
    end


      it "accepts a toc string" do
        subject.toc.must_equal toc
      end

    describe "#query" do
      it "returns properly formed xml" do
        #`Ox.load` returns Ox::ParseError if xml is malformed
        Ox.load(subject.query).must_be_kind_of Ox::Element
      end

      it "returns the correct query" do
        subject.query.must_include "182 "
        subject.query.must_include "98702 "
        subject.query.must_include 'cmd="ALBUM_TOC"'
        subject.query.must_include "SINGLE_BEST_COVER"
      end
    end
  end
end
