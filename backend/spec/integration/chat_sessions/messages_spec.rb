require 'swagger_helper'
require Rails.root.join('app', 'controllers', 'chat_sessions', 'messages_controller')

RSpec.describe 'ChatSessions::Messages', type: :request do
  let!(:user) { User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
  let(:auth_token) { JwtService.encode(sub: user.id, exp: 24.hours.from_now.to_i) }
  let(:Authorization) { "Bearer #{auth_token}" }

  let!(:chat_session) { ChatSession.create!(user: user, title: 'My AI Chat') }

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

  path '/chat_sessions/{chat_session_id}/messages' do
    get 'Fetch full message history' do
      tags 'Messages'
      consumes 'application/json'
      produces 'application/json'
      security [ { bearerAuth: [] } ]
      parameter name: :chat_session_id, in: :path, type: :string

      response '200', 'messages retrieved' do
        let!(:message) { Message.create!(content: "Hello!", role: :user, chat_session: chat_session) }
        let(:chat_session_id) { chat_session.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:chat_session_id) { chat_session.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Unauthorized')
        end
      end
    end

    post 'Send a message, get AI response' do
      tags 'Messages'
      consumes 'application/json'
      produces 'application/json'
      security [ { bearerAuth: [] } ]
      parameter name: :chat_session_id, in: :path, type: :string
      parameter name: :message, in: :body, schema: {
        type: :object,
        properties: {
          content: { type: :string },
          tone: { type: :string }
        },
        required: [ 'content' ]
      }

      response '200', 'message sent and AI responded' do
        let(:chat_session_id) { chat_session.id }
        let(:message) { { content: 'Hello AI!' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user_message']['content']).to eq(message[:content])
          expect(data['user_message']['role']).to eq("user")
          expect(data['ai_message']['content']).to eq("Hello from AI!")
          expect(data['ai_message']['role']).to eq("assistant")
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:chat_session_id) { chat_session.id }
        let(:message) { { content: 'Hello AI!' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Unauthorized')
        end
      end
    end
  end
end
