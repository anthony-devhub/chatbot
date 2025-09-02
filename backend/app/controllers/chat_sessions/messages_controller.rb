class ChatSessions::MessagesController < ApplicationController
  before_action :set_chat_session

  def index
    render json: @chat_session.messages.order(:created_at)
  end

  def create
    content = params[:content].to_s.strip
    if content.blank?
      return render json: { error: "Message content can't be blank" }, status: :unprocessable_entity
    end
    # store user message
    user_message = @chat_session.messages.create!(role: :user, content: params[:content])

    # build prompt for AI; limited to 3 messages only to keep it cheap in this demo.
    prompt = @chat_session.messages.order("created_at desc").limit(3).map do |m|
      { role: m.role, content: m.content }
    end

    # call AI
    service = OpenRouterService.new(messages: prompt, tone: params[:tone])
    ai_response_text = service.call

    # store AI response
    ai_message = @chat_session.messages.create!(role: :assistant, content: ai_response_text)

    render json: { user_message: user_message, ai_message: ai_message, tone: params[:tone] }
  end

  private

  def set_chat_session
    @chat_session = current_user.chat_sessions.find(params[:chat_session_id])
  end
end
