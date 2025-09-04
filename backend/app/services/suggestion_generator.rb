class SuggestionGenerator
  def initialize(chat_session:, partial_content:)
    @chat_session = chat_session
    @partial_content = partial_content
  end

  def call
    messages = @chat_session.messages.order(:created_at).last(3).map do |msg|
      { role: msg.role, content: msg.content }
    end

    prompt = <<~PROMPT
      Conversation so far:
      #{messages.map { |m| "#{m[:role]}: #{m[:content]}" }.join("\n")}

      The user has started typing:
      "#{@partial_content}"

      Predict how the user might continue this sentence (max 3).
      Keep them short, natural, and conversational.
      Always return your answer as a valid JSON array of strings.
    PROMPT

    service = OpenRouterService.new(
      messages: [
        { role: "system", content: "You are a helpful assistant suggesting natural next replies." },
        { role: "user", content: prompt }
      ]
    )
    response = service.call
    cleaned = response
            .gsub(/\A```json\s*/, "") # remove leading ```json
            .gsub(/```$/, "")         # remove trailing ```
            .strip

    JSON.parse(cleaned)
  end
end
