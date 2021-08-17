require_relative '../../../app/api'
require 'rack/test'
require  'active_support/core_ext/hash/conversions'
module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:expense) { { 'some' => 'data' } }
    let(:response_body) { JSON.parse(last_response.body) }
    let(:date) { '2018-09-21' }
    let(:data) do
      {
        'payee' => 'Zoo',
        'amount' => 15.25,
        'date' => '2017-06-10'
      }
    end

    describe 'GET /expenses/:date' do
      before do
        allow(ledger).to receive(:expenses_on)
          .with(date)
          .and_return(data)
      end
      context 'when expenses exist on the given date' do
        it 'returns the expense records as JSON' do
          get "/expenses/#{date}"
          expect(last_response.body).to include('Zoo')
        end

        it 'responds with a 200(ok)' do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        let(:data) { [] }
        it 'returns the expense records as JSON' do
          get "/expenses/#{date}"
          expect(last_response.body).to eq('[]')
        end

        it 'responds with a 200(ok)' do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end
    end

    describe 'POST /expenses' do
      before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
      end

        context 'when the expense is successfully recorded' do
          it 'returns the expense id' do
            post '/expenses', JSON.generate(expense)
            parsed = response_body
            expect(parsed).to include('expense_id' => 417)
          end


          it 'responds with a 200 (OK)' do
            post '/expenses', JSON.generate(expense)
            expect(last_response.status).to eq(200)
          end
        end


      context 'when the expense fails validation' do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end
        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          parsed = response_body
          expect(parsed).to include('error' => 'Expense incomplete')
        end
        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end
  end
end
