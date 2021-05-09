module Loan
  module Calc
    class FullyDeferred < Common
      def initialize(
        amount:,
        duration:,
        period_duration:,
        annual_rate:,
        due_on: Date.today,
        deferred: 0,
        deferred_and_capitalized: 0,
        realistic_interests_duration: false,
        starting_delta: 0,
        starting_capitalized_interests: 0)
        super
      end

      def amount_to_capitalize(index:)
        super do
          @deferred_start_amount_to_capitalize
        end
      end

      def capital_reimbursed(index:)
        super do
          @deferred_start_amount_to_capitalize
        end
      end

      def term(index:)
        super do |term|
          term[:period_capital] = @amount
          term[:period_calculated_interests] = interests_calculator.period_interests(
            amount: amount_to_capitalize(index: index)
          )
          term[:capitalized_interests_start] = @max_capitalized_interests
          term[:capitalized_interests_end] = bigd(0)
          term[:period_interests] = term[:period_calculated_interests] + @max_capitalized_interests
        end
      end
    end
  end
end

