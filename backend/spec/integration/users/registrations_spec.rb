require 'swagger_helper'

RSpec.describe 'Users::Registrations', type: :request do
  path '/users/signup' do
    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: ['email', 'password', 'password_confirmation']
          }
        }
      }

      response '200', 'user created' do
        let(:user) do
          {
            user: {
              email: 'test@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end
        let(:raw_post) { user.to_json }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) do
          {
            user: {
              email: 'bad_email',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end
        let(:raw_post) { user.to_json }
        run_test!
      end
    end
  end
end
