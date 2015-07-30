require_relative '../../spec_helper.rb'

module UnderFire
  describe Response do
    it "works" do
      Response.new(res).must_be Array
    end
  end
end
