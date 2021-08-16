require 'json'
require 'sinatra/base'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)
  class Ledger
    def record(expense)
     # RecordResult.new(true, 41, nil)
    end

    def expenses_on(date)

    end
  end
end
