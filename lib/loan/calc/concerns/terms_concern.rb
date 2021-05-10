
module Loan
  module Calc
    module TermsConcern
      extend ActiveSupport::Concern

      included do
        def deferred_and_capitalized_term(index:)
          {
            index: index,
            due_on: due_on + (index * period_duration).months,
            period_capital: bigd(0),
            period_interests: bigd(0)
          }.tap do |term|
            term[:capitalized_interests_start] = (
              @starting_capitalized_interests + interests_calculator.capitalize(
                amount: @start_amount_to_capitalize,
                duration: index - 1
              )
            )

            term[:capitalized_interests_end] = (
              @starting_capitalized_interests + interests_calculator.capitalize(
                amount: @start_amount_to_capitalize,
                duration: index
              )
            )

            term[:period_calculated_interests] = (
              term[:capitalized_interests_end] - term[:capitalized_interests_start]
            )
          end
        end

        def deferred_term(index:)
          {
            index: index,
            due_on: due_on + (index * period_duration).months,
            period_capital: bigd(0),
            period_interests: interests_calculator.period_interests(
              amount: @deferred_start_amount_to_capitalize,
              index: index
            ),
            capitalized_interests_start: @max_capitalized_interests,
            capitalized_interests_end: @max_capitalized_interests
          }.tap do |term|
            term[:period_calculated_interests] = term[:period_interests]
          end
        end

        def term(index:)
          {
            index: index,
            due_on: due_on + (index * period_duration).months,
          }.tap do |term|
            yield term
          end
        end
      end
    end
  end
end
