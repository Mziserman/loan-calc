module Loan
  module Calc
    class Linear < Common
      def initialize(*args)
        super do
          @period_capital = @deferred_start_amount_to_capitalize.div(
            non_deferred_duration,
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
          @period_capital.mult(
            (index - deferred_and_capitalized - deferred),
            BIG_DECIMAL_DIGITS
          )
        end
      end

      def term(index:)
        {
          index: index,
          due_on: due_on + (index * period_duration).months,
          period_capital: @period_capital,
          period_interests: interests_calculator.period_interests(
            amount: amount_to_capitalize(index: index)
          )
        }.tap do |term|
          reimburse_capitalized_interests(term: term)
        end
      end
    end
  end
end
