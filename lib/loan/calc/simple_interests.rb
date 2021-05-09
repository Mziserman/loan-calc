module Loan
  module Calc
    class SimpleInterests < Interests
      attr_accessor :period_rate

      def initialize(annual_rate:, period_duration:)
        @period_rate = annual_rate * period_duration / 12.0
      end
    end
  end
end
