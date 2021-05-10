module Loan
  module Calc
    module TimetableModifierConcern
      extend ActiveSupport::Concern

      included do
        def apply_deltas(timetable:)
          accrued_delta = starting_delta
          timetable.each do |term|
            rounded_interests = term[:period_interests].round(2)
            delta = term[:period_interests] - rounded_interests
            accrued_delta += delta
            term[:accrued_delta] = accrued_delta
            amount_to_add = accrued_delta.truncate(2)
            if amount_to_add != bigd(0)
              term[:period_interests] += amount_to_add
              accrued_delta -= amount_to_add
            end
            term[:amount_added] = amount_to_add
          end

          timetable
        end

        def round(timetable:)
          timetable.each do |term|
            term[:period_interests] = term[:period_interests].round(2)
            term[:period_capital] = term[:period_capital].round(2)
          end

          timetable
        end
      end
    end
  end
end
