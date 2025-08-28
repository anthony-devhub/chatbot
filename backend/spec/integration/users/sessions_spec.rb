require 'swagger_helper'

RSpec.describe 'Users::Sessions API', type: :request do
  path '/users/signin' do
    post 'Authenticate a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }

      response '201', 'user authenticated' do
        let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:credentials) { { email: user.email, password: 'password123' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['token']).to be_present
          expect(data['user']).to include('id' => user.id, 'email' => user.email)
        end
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'test@example.com', password: 'wrong' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Invalid email or password')
        end
      end
    end
  end

  path '/users/signout' do
    delete 'Log out a user' do
      tags 'Users'
      produces 'application/json'

      response '204', 'user logged out' do
        run_test!
      end
    end
  end
end