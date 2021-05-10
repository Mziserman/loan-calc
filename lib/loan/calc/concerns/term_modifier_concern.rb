
module Loan
  module Calc
    module TermModifierConcern
      extend ActiveSupport::Concern

      included do
        def last_term(term:)
          term[:period_capital] = (
            @deferred_start_amount_to_capitalize -
            capital_reimbursed(index: term[:index] - 1)
          )
        end

        def reimburse_capitalized_interests(term:)
          term[:period_calculated_interests] = term[:period_interests]

          term[:capitalized_interests_start] = [
            bigd(0),
            @max_capitalized_interests - capital_reimbursed(index: term[:index] - 1)
          ].max

          term[:capitalized_interests_end] = [
            bigd(0),
            @max_capitalized_interests - capital_reimbursed(index: term[:index])
          ].max

          diff = term[:capitalized_interests_start] - term[:capitalized_interests_end]

          term[:period_capital] -= diff
          term[:period_interests] += diff
        end
      end
    end
  end
end
