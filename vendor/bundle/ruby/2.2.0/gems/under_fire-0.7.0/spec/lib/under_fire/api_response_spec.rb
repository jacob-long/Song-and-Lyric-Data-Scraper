require_relative '../../spec_helper.rb'
require 'nori'

module UnderFire
  describe APIResponse do
    let(:file_name){"../../../sample/response.xml"}
    let(:res){File.open(File.expand_path file_name, __FILE__) {|f| f.read}}
    subject{APIResponse.new(res)}

    describe "#parse_response" do
      it "returns a Hash" do
        subject.to_h.must_be_kind_of Hash
      end
    end
  end
end
