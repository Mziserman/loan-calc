module Loan
  module Calc
    class Factory
      def self.create(
        amount:,
        duration:,
        period_duration:,
        annual_rate:,
        type: Loan::Calc::Linear,
        due_on: Date.today,
        deferred_and_capitalized: 0,
        deferred: 0,
        interests_calculator_type: :interests,
        starting_delta: 0,
        starting_capitalized_interests: 0
      )
        if deferred_and_capitalized + deferred == duration - 1
          type = Loan::Calc::FullyDeferred
        end

        type.new(
          amount: amount,
          duration: duration,
          period_duration: period_duration,
          annual_rate: annual_rate,
          due_on: due_on,
          deferred_and_capitalized: deferred_and_capitalized,
          deferred: deferred,
          interests_calculator_type: interests_calculator_type,
          starting_delta: starting_delta,
          starting_capitalized_interests: starting_capitalized_interests
        )
      end
    end
  end
end
