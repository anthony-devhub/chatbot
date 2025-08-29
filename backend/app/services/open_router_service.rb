require 'net/http'
require 'uri'
require 'json'

class OpenRouterService
  OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions'
  API_KEY = ENV['OPENROUTER_API_KEY']

  def initialize(messages:)
    @messages = messages
  end

  def call
    uri = URI.parse(OPENROUTER_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{API_KEY}" })
    request.body = {
      model: 'gpt-4o-mini',
      messages: @messages
    }.to_json

    response = http.request(request)
    body = JSON.parse(response.body)

    if response.code.to_i == 200
      body.dig('choices', 0, 'message', 'content')
    else
      Rails.logger.error("OpenRouter error: #{body}")
      "Sorry, I couldn't process that."
    end
  rescue StandardError => e
    Rails.logger.error("OpenRouterService exception: #{e.message}")
    "Sorry, something went wrong."
  end
end
