module Loan
  module Calc
    class RealisticInterests
      def initialize(annual_rate:, period_duration:, due_on:, duration:)
        @annual_rate = annual_rate
        @period_duration = period_duration
        @due_on = due_on
        @duration = duration

        create_calendar
      end

      def create_calendar
        @calendar = (1..duration).map do |index|
          due_on + (index - 1).months
        end
      end
    end
  end
end
