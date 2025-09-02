require "net/http"
require "uri"
require "json"

class OpenRouterService
  OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions"
  API_KEY = ENV["OPENROUTER_API_KEY"]

  TONE_PROMPTS = {
    "friendly" => "You are a friendly assistant. Be warm, casual, and approachable.",
    "sarcastic" => "You are a sarcastic assistant. Be witty, playful, and cutting.",
    "professional" => "You are a professional assistant. Be clear, concise, and formal.",
    "mentor" => "You are a mentor. Be supportive, thoughtful, and provide guidance."
  }.freeze

  def initialize(messages:, model: "gpt-4o-mini", tone: nil)
    @messages = messages
    @model = model
    @tone = tone
  end

  def call
    uri = URI.parse(OPENROUTER_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json", "Authorization" => "Bearer #{API_KEY}" })
    request.body = {
      model: "gpt-4o-mini",
      messages: apply_tone(@messages, @tone)
    }.to_json

    response = http.request(request)
    body = JSON.parse(response.body) rescue {}

    if response.code.to_i == 200
      body.dig("choices", 0, "message", "content")
    else
      Rails.logger.error("OpenRouter error: #{body}")
      "Sorry, I couldn't process that."
    end
  rescue StandardError => e
    Rails.logger.error("OpenRouterService exception: #{e.message}")
    "Sorry, something went wrong."
  end

  private

  def apply_tone(messages, tone)
    return messages unless tone && TONE_PROMPTS.key?(tone)

    system_prompt = { role: "system", content: TONE_PROMPTS[tone] }
    [system_prompt] + messages
  end
end
