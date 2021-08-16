require 'json'
require 'sinatra/base'
require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)
  REQUIRED_KEYS = ['payee', 'date', 'amount']
  class Ledger
    def record(expense)
      errors = validate_fields(expense.keys)
    unless  errors == ""
      message = "Invalid expense: #{errors} is required"
      return RecordResult.new(false, nil, message)
    end
     DB[:expenses].insert(expense)
     id = DB[:expenses].max(:id)
     RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end

    def validate_fields(params)
      invalid_params = REQUIRED_KEYS - params
      if (invalid_params.length > 1)
        invalid_params.join(", ").to_s
      elsif (invalid_params.length == 1)
        invalid_params[0]
      else
        ""
      end
    end
  end
end
