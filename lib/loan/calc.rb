require 'active_support/all'
require 'bigdecimal'

require 'loan/calc/initializers/big_decimal'
require 'loan/calc/concerns/big_decimal_concern'
require 'loan/calc/concerns/pretty_print_concern'
require 'loan/calc/version'

module Loan
  module Calc
    class Error < StandardError; end

    BIG_DECIMAL_DIGITS = 14

    autoload :Standard, 'loan/calc/standard'
    autoload :Common, 'loan/calc/common'
    autoload :SimpleInterests, 'loan/calc/simple_interests'
    autoload :Factory, 'loan/calc/factory'
    autoload :FullyDeferred, 'loan/calc/fully_deferred'
    autoload :Linear, 'loan/calc/linear'
    autoload :Interests, 'loan/calc/interests'
  end
end
