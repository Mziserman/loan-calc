module Loan
  module Calc
    class Standard < Common
      def initialize(*args)
        super do
          compound = (1 + interests_calculator.period_rate)**non_deferred_duration
          @period_total = @deferred_start_amount_to_capitalize.mult(
            interests_calculator.period_rate.mult(compound, BIG_DECIMAL_DIGITS).div(
              compound - 1,
              BIG_DECIMAL_DIGITS
            ),
            BIG_DECIMAL_DIGITS
          )
        end
      end

      def amount_to_capitalize(index:)
        super do
          @deferred_start_amount_to_capitalize - capital_reimbursed(index: index - 1)
        end
      end

      def capital_reimbursed(index:)
        super do
          reimbursed = bigd(0)
          (1..(index - deferred_and_capitalized - deferred)).each do |_|
            interests_part = interests_calculator.period_interests(
              amount: @deferred_start_amount_to_capitalize - reimbursed
            )
            reimbursed += bigd(@period_total - interests_part).round(2)
          end
          reimbursed
        end
      end

      def term(index:)
        {
          index: index,
          due_on: due_on + (index * period_duration).months,
          period_interests: interests_calculator.period_interests(
            amount: amount_to_capitalize(index: index)
          )
        }.tap do |term|
          term[:period_capital] = @period_total - term[:period_interests]
          reimburse_capitalized_interests(term: term)
          last_term(term: term) if index == duration
        end
      end
    end
  end
end
