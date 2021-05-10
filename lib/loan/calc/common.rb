module Loan
  module Calc
    class Common

      def self.create(*_, **kwargs)
        Loan::Calc::Factory.create(type: name.constantize, **kwargs)
      end

      include BigDecimalConcern
      include PrettyPrintConcern
      include TermsConcern
      include TimetableModifierConcern
      include TermModifierConcern

      attr_accessor :amount,
                    :duration,
                    :period_duration,
                    :annual_rate,
                    :due_on,
                    :deferred_and_capitalized,
                    :deferred,
                    :interests_calculator,
                    :starting_delta,
                    :starting_capitalized_interests

      def initialize(
        amount:,
        duration:,
        period_duration:,
        annual_rate:,
        due_on: Date.today,
        deferred_and_capitalized: 0,
        deferred: 0,
        interests_calculator_type: :interests,
        starting_delta: 0,
        starting_capitalized_interests: 0,
        &block
      )

        @amount = bigd(amount)
        raise 'amount must be positive' if amount <= 0

        @duration = duration
        raise 'duration must be positive' if duration <= 0

        @period_duration = period_duration
        raise 'period_duration must be positive' if duration <= 0

        @annual_rate = bigd(annual_rate)
        @due_on = due_on
        @deferred = deferred
        @deferred_and_capitalized = deferred_and_capitalized
        raise 'can\'t defer more than duration - 1' if deferred + deferred_and_capitalized > duration - 1

        @interests_calculator =
          case interests_calculator_type
          when :interests
            Interests.new(
              annual_rate: @annual_rate,
              period_duration: period_duration
            )
          when :simple
            SimpleInterests.new(
              annual_rate: @annual_rate,
              period_duration: period_duration
            )
          when :realistic
            RealisticInterests.new(
              annual_rate: @annual_rate,
              period_duration: period_duration,
              due_on: due_on,
              duration: duration
            )
          end

        @starting_delta = bigd(starting_delta)
        raise 'starting delta must be below 0.01' if @starting_delta > 0.01
        raise 'starting delta must be above -0.01' if @starting_delta < -0.01

        @starting_capitalized_interests = bigd(starting_capitalized_interests)

        @start_amount_to_capitalize = @amount + @starting_capitalized_interests
        @max_capitalized_interests = @starting_capitalized_interests + interests_calculator.capitalize(
          amount: @start_amount_to_capitalize,
          duration: deferred_and_capitalized
        )

        @deferred_start_amount_to_capitalize = @amount + @max_capitalized_interests

        yield if block_given?
      end

      def timetable
        timetable = (1..duration).map do |index|
          if index <= deferred_and_capitalized
            deferred_and_capitalized_term(index: index)
          elsif index <= deferred_and_capitalized + deferred
            deferred_term(index: index)
          else
            term(index: index)
          end
        end

        apply_deltas(timetable: timetable)
        round(timetable: timetable)
      end

      def non_deferred_duration
        duration - (deferred_and_capitalized + deferred)
      end

      def capital_reimbursed(index:)
        if index <= deferred_and_capitalized
          bigd(0)
        elsif index <= deferred_and_capitalized + deferred
          bigd(0)
        else
          yield
        end
      end

      def amount_to_capitalize(index:)
        if index <= deferred_and_capitalized
          @start_amount_to_capitalize +
            interests_calculator.capitalize(amount: @start_amount_to_capitalize, duration: index)
        elsif index <= deferred_and_capitalized + deferred
          @deferred_start_amount_to_capitalize
        else
          yield
        end
      end
    end
  end
end
