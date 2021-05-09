require 'csv'
require 'pry'

RSpec.describe Loan::Calc do
  def loan_from_filename(filename)
    split = filename.split('/').last.gsub('.csv', '').split('_')
    interests_calculator_type = :simple
    if split.first == 'realistic'
      split = split[1..]
      interests_calculator_type = :realistic
    end
    split = ['in_fine'] + split[2..] if split.first == 'in'

    duration = split[4].to_i
    type = split[0]
    deferred = 0
    deferred_and_capitalized = 0
    deferred += split[5].to_i

    if type == 'in_fine'
      type = 'standard'
      deferred = duration - 1
    elsif type == 'bullet'
      type = 'standard'
      deferred_and_capitalized = duration - 1
    end
    period_duration = {
      month: 1,
      quarter: 3,
      semester: 6,
      year: 12
    }[split[1].to_sym]

    "Loan::Calc::#{type.classify}".constantize.create(
      amount: split[2].to_f,
      duration: duration,
      period_duration: period_duration,
      annual_rate: split[3].to_f / 100,
      due_on: Date.parse(split[6]),
      deferred: deferred,
      deferred_and_capitalized: deferred_and_capitalized,
      interests_calculator_type: interests_calculator_type
    )
  end

  Dir['./spec/fixtures/*.csv'].each do |filename|
    context filename do
      it 'works' do
        expected = CSV.parse(File.open(filename))
        loan = loan_from_filename(filename)
        csv_columns = %w[
          index
          due_on
          crd_beginning_of_period
          remaining_capital
          period_calculated_interests
          delta
          accrued_delta
          amount_to_add
          period_interests
          period_capital
          total_paid_capital_end_of_period
          total_paid_interests_end_of_period
          period_total
          capitalized_interests_start
          capitalized_interests_end
        ]

        loan.timetable.each.with_index do |term, index|
          expect(term[:index]).to eq(expected[index][csv_columns.index('index')].to_i)
          expect(term[:due_on]).to eq(Date.strptime(expected[index][csv_columns.index('due_on')], '%m/%d/%Y'))
          expect(term[:period_interests]).to be_within(0.01).of(expected[index][csv_columns.index('period_interests')].to_f)
          expect(term[:period_capital]).to be_within(0.01).of(expected[index][csv_columns.index('period_capital')].to_f)
          # expect(term[:accrued_delta]).to be_within(0.005).of(expected[index][csv_columns.index('accrued_delta')].to_f)
          expect(term[:capitalized_interests_start]).to be_within(0.005).of(expected[index][csv_columns.index('capitalized_interests_start')].to_f)
          expect(term[:capitalized_interests_end]).to be_within(0.005).of(expected[index][csv_columns.index('capitalized_interests_end')].to_f)
        end
      end
    end
  end
end

# CSV.open(filename, 'w') do |csv|
#   expected.each do |row|
#     csv << row
#   end
# end
