require 'swagger_helper'
require Rails.root.join('app', 'controllers', 'chat_sessions', 'suggestions_controller')
RSpec.describe "ChatSessions::Suggestions", type: :request do
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
              message: { content: "[\n    \"improve my skills.\",\n    \"a vacation.\",\n    \"exercise more.\"\n]" }
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
  path "/chat_sessions/{chat_session_id}/suggestions" do
    get "Generate suggestions for partial content" do
      tags "Suggestions"
      consumes "application/json"
      produces "application/json"
      security [ { bearerAuth: [] } ]
      parameter name: :chat_session_id, in: :path, type: :string, description: "ID of the chat session"
      parameter name: :partial_content, in: :query, type: :string, description: "Partial content text"

      let(:chat_session_id) { chat_session.id }

      response "200", "Suggestions generated" do
        let(:partial_content) { "Hello, I was thinking about" }

        schema type: :object,
               properties: {
                 suggestions: {
                   type: :array,
                   items: { type: :string }
                 }
               },
               required: [ "suggestions" ]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["suggestions"]).to be_an(Array)
          expect(data["suggestions"].first).to include("improve my skills.")
        end
      end

      response "422", "Missing partial_content" do
        let(:partial_content) { "" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["error"]).to eq("partial_content is required")
        end
      end
    end
  end
end
