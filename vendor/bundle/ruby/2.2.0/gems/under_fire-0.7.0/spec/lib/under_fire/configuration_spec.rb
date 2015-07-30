require_relative '../../spec_helper'
require 'pry'

module UnderFire
  describe Configuration do
    let(:base_dir){File.expand_path(__FILE__ + "/../../..")}
    let(:config_file){File.join(base_dir, 'fixtures/.ufrc')}

    before do
      ENV["GRACENOTE_USER_ID"] = "12354534"
      ENV["GRACENOTE_CLIENT_ID"] = "1252545-34543523452345"
     end

    after do
      Configuration.instance.reset
    end

    describe "a completed configuration" do

      it "has a client_id" do
        config = Configuration.instance
        config.client_id.must_equal "1252545-34543523452345"
      end

      it "has a user_id" do
        config = Configuration.instance
        config.user_id.must_equal "12354534"
      end
    end

    describe "unconfigured" do
      before do
        ENV["GRACENOTE_CLIENT_ID"] = ""
        ENV["GRACENOTE_USER_ID"] = ""
      end

      describe "#configured?" do
        it "returns false if there are no credentials" do
          config = Configuration.instance
          config.configured?.must_equal false
        end
      end
    end
  end
end
