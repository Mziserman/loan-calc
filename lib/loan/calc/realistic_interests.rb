module Loan
  module Calc
    class RealisticInterests
      include BigDecimalConcern
      attr_accessor :annual_rate, :period_duration, :due_on, :duration
      def initialize(annual_rate:, period_duration:, due_on:, duration:)
        @annual_rate = annual_rate
        @period_duration = period_duration
        @due_on = due_on
        @duration = duration

        @calendar = calendar
        @periods_rates = periods_rates
      end

      def capitalize(amount:, duration:, **_args)
        capitalized = 0
        (1..duration).each do |index|
          capitalized += (amount + capitalized).mult(
            period_rate(index: index),
            BIG_DECIMAL_DIGITS
          )
        end

        capitalized
      end

      def calendar
        (1..duration).map do |index|
          due_on + (index * period_duration).months
        end
      end

      def mean_period_rate
        @periods_rates.sum.div(@periods_rates.count, BIG_DECIMAL_DIGITS)
      end

      def period_rate(index: nil)
        return @periods_rates[index - 1] if index.present?

        mean_period_rate
      end

      def period_interests(amount:, index:)
        amount.mult(period_rate(index: index), BIG_DECIMAL_DIGITS)
      rescue => e

        binding.pry
      end

      def periods_rates
        previous_date = due_on
        periods_rates = []
        @calendar.each do |next_date|
          periods_rates << calculate_period_rate(from: previous_date, to: next_date)
          previous_date = next_date
        end
        require 'pry'
        # binding.pry

        periods_rates
      end

      def leap_days_count(from:, to:)
        start_year = from.year
        end_year = to.year

        (start_year..end_year).sum do |year|
          next 0 unless Date.gregorian_leap?(year)

          start_date =
            if start_year == year
              from
            else
              Date.new(year - 1, 12, 31)
            end

          end_date =
            if end_year == year
              to
            else
              Date.new(year, 12, 31)
            end

          end_date - start_date
        end
      end

      def calculate_period_rate(from:, to:)
        total_days = to - from
        leap_days = bigd(leap_days_count(from: from, to: to))
        non_leap_days = bigd(total_days - leap_days)

        annual_rate.mult(
          leap_days.div(366, BIG_DECIMAL_DIGITS) +
          non_leap_days.div(365, BIG_DECIMAL_DIGITS),
          BIG_DECIMAL_DIGITS
        )
      end
    end
  end
end
