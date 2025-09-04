class ChatSessionsController < ApplicationController
  def create
    chat_session = current_user.chat_sessions.create!(title: params[:title] || "Conversation with AI")

    if params[:initial_message].present?
      user_message = chat_session.messages.create!(role: :user, content: params[:initial_message])

      prompt = chat_session.messages.order(:created_at).map do |m|
        { role: m.role, content: m.content }
      end

      ai_response_text = call_ai(messages: prompt, tone: params[:tone])

      ai_message = chat_session.messages.create!(role: :assistant, content: ai_response_text)

      render json: { chat_session: chat_session, user_message: user_message, ai_message: ai_message, tone: params[:tone] }, status: :created
    else
      render json: { chat_session: chat_session }, status: :created
    end
  end

  def summarize
    chat_session = ChatSession.find(params[:id])

    transcript = chat_session.messages.order(:created_at).map do |m|
      { role: m.role, content: m.content }
    end

    ai_response_text = summarize_messages(transcript)

    ai_message = chat_session.messages.create!(role: :assistant, content: ai_response_text)

    render json: { chat_session: chat_session, ai_message: ai_message }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Chat session not found" }, status: :not_found
  end
end
