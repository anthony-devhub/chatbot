class ChatSessionsController < ApplicationController
  def create
    chat_session = current_user.chat_sessions.create!(title: params[:title] || "Conversation with AI")

    if params[:initial_message].present?
      user_message = chat_session.messages.create!(role: :user, content: params[:initial_message])
      prompt = chat_session.messages.order(:created_at).map do |m|
        { role: m.role, content: m.content }
      end
      service = OpenRouterService.new(messages: prompt)
      ai_response_text = service.call
      ai_message = chat_session.messages.create!(role: :assistant, content: ai_response_text)

      render json: { chat_session: chat_session, user_message: user_message, ai_message: ai_message }, status: :created
    else
      render json: { chat_session: chat_session }, status: :created
    end
  end

  def summarize
    chat_session = ChatSession.find(params[:id])

    transcript = chat_session.messages.order(:created_at).map { |m| "#{m.role}: #{m.content}" }.join("\n")

    service = OpenRouterService.new(messages: [
      { role: "system", content: "Summarize the following chat into a concise, neutral summary." },
      { role: "user", content: transcript }
    ])
    ai_response_text = service.call

    ai_message = chat_session.messages.create!(role: :assistant, content: ai_response_text)

    render json: { chat_session: chat_session, ai_message: ai_message }
  end
end
