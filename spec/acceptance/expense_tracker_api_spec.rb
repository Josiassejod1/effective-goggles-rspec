require 'rack/test'
require 'json'
require_relative '../../app/api'

module ExpenseTracker
  RSpec.describe 'Expense Tracker Api' do
    include Rack::Test::Methods

    it 'records submitted expenses' do
      coffee = post_expense(
        {
          'payee' => 'Starbucks',
          'amount' => 5.75,
          'date' => '2017-06-10'
        }
      )

      zoo = post_expense(
        {
          'payee' => 'Zoo',
          'amount' => 15.25,
          'date' => '2017-06-10'
        }
      )

      groceries = post_expense(
        {
          'payee' => 'Whole Foods',
          'amount' => 95.20,
          'date' => '2017-06-11'
        }
      )
    end

    it 'record submitted expenses' do
      pending 'Need to persist expenses'
      coffee = post_expense(
        {
          'payee' => 'Starbucks',
          'amount' => 5.75,
          'date' => '2017-06-10'
        }
      )

      zoo = post_expense(
        {
          'payee' => 'Zoo',
          'amount' => 15.25,
          'date' => '2017-06-10'
        }
      )
      get '/expenses/2017-06-10'
      expenses = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(expenses).to contain_exactly(coffee, zoo)
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))
      expense.merge('id' => parsed['expense_id'])
    end

    def app
      ExpenseTracker::API.new
    end
  end
end
