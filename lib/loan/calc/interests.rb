module Loan
  module Calc
    class Interests
      attr_accessor :period_rate

      def initialize(annual_rate:, period_duration:)
        @period_rate = (1.0 + annual_rate)**(period_duration / 12.0) - 1
      end

      def period_interests(amount:, **_args)
        amount.mult(period_rate, BIG_DECIMAL_DIGITS)
      end

      def capitalize(amount:, duration:, **_args)
        amount.mult(
          (1 + period_rate)**duration,
          BIG_DECIMAL_DIGITS
        ) - amount
      end
    end
  end
end
