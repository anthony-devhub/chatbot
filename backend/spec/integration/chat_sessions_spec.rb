require 'swagger_helper'

RSpec.describe 'ChatSessions API', type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:auth_token) { JwtService.encode(sub: user.id, exp: 24.hours.from_now.to_i) }
  let(:Authorization) { "Bearer #{auth_token}" }

  before do
    stub_request(:post, "https://openrouter.ai/api/v1/chat/completions")
      .with(
        headers: {
          'Authorization' => "Bearer #{ENV['OPENROUTER_API_KEY']}",
          'Content-Type' => 'application/json'
        }
      )
      .to_return(
        status: 200,
        body: {
          choices: [
            {
              message: { content: "Hello from AI!" }
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  path '/chat_sessions' do
    post 'Create a new chat session (optional initial message)' do
      tags 'Messages'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearerAuth: [] }]
      parameter name: :chat_session, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          initial_message: { type: :string }
        }
      }
      # parameter name: :Authorization, in: :header, type: :string, required: true

      response '201', 'chat session created' do
        let(:chat_session) { { title: 'My First AI Chat', initial_message: 'Hello AI!' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['chat_session']['title']).to eq('My First AI Chat')
          expect(WebMock).to have_requested(:post, "https://openrouter.ai/api/v1/chat/completions")
            .with(
              headers: {
                'Authorization' => "Bearer #{ENV['OPENROUTER_API_KEY']}",
                'Content-Type' => 'application/json'
              }
            )
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:chat_session) { { title: 'No Auth' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Unauthorized')
        end
      end
    end
  end
end
