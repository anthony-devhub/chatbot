class ChatSessions::MessagesController < ApplicationController
  before_action :set_chat_session

  def index
    render json: @chat_session.messages.order(:created_at)
  end

  def create
    # store user message
    user_message = @chat_session.messages.create!(role: :user, content: params[:content])

    # build prompt for AI
    prompt = @chat_session.messages.order(:created_at).map do |m|
      { role: m.role, content: m.content }
    end

    # call AI
    service = OpenRouterService.new(messages: prompt)
    ai_response_text = service.call

    # store AI response
    ai_message = @chat_session.messages.create!(role: :assistant, content: ai_response_text)

    render json: { user_message: user_message, ai_message: ai_message }
  end

  private

  def set_chat_session
    @chat_session = current_user.chat_sessions.find(params[:chat_session_id])
  end
end
