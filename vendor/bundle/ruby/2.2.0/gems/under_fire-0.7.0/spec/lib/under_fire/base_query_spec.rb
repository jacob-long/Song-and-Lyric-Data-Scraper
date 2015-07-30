require_relative "../../spec_helper"

module UnderFire
  describe BaseQuery do
    describe "instatiation" do
      it "must accept a query mode" do
        BaseQuery.new("SINGLE_BEST").mode.must_equal "SINGLE_BEST"
      end

      it "must default to SINGLE_BEST_COVER" do
        BaseQuery.new().mode.must_equal "SINGLE_BEST_COVER"
      end
    end
  end
end
