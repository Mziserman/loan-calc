module Loan
  module Calc
    module BigDecimalConcern
      extend ActiveSupport::Concern

      included do
        def bigd(value)
          BigDecimal(value, BIG_DECIMAL_DIGITS)
        end
      end
    end
  end
end
