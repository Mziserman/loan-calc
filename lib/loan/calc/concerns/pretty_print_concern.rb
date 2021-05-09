require 'table_print'

module Loan
  module Calc
    module PrettyPrintConcern
      extend ActiveSupport::Concern

      included do
        def pp
          tp(
            timetable,
            { t: { display_method: proc { |term| term[:index] } } },
            { date: { display_method: proc { |term| term[:due_on].strftime("%d/%m/%Y") } } },
            { period_capital: { display_method: proc { |term| term[:period_capital].round(2) } } },
            { period_interests: { display_method: proc { |term| term[:period_interests].round(2) } } },
            { capitalized_start: { display_method: proc { |term| term[:capitalized_interests_start].round(2) } } },
            { capitalized_end: { display_method: proc { |term| term[:capitalized_interests_end].round(2) } } },
            { calc_int: { display_method: proc { |term| term[:period_calculated_interests].round(2) } } }
          )
        end
      end
    end
  end
end
