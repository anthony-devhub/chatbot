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
    user_message = @chat_session.messages.create!(role: :user, content: content)

    # Check if we should create a summary
    maybe_checkpoint_summary!

    # build prompt for AI
    prompt = build_prompt

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
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Chat session not found" }, status: :not_found
  end

  # Every 2 user messages => create a summary
  def maybe_checkpoint_summary!
    user_message_count = @chat_session.messages.where(role: :user).count
    return unless (user_message_count % 2).zero?

    # Grab last N messages and summarize them
    recent_messages = @chat_session.messages.order(:created_at).last(20).map do |m|
      { role: m.role, content: m.content }
    end

    summary_service = OpenRouterService.new(messages: recent_messages, tone: "neutral")
    summary_text = summary_service.call

    @chat_session.conversation_summaries.create!(content: summary_text, turn_count: user_message_count)
  end

  # Combine last 2 summaries + last 2 raw messages
  def build_prompt
    summaries = @chat_session.conversation_summaries.order(:created_at).last(2).map do |s|
      { role: "system", content: "Summarize the following chat into a concise summary.: #{s.content}" }
    end

    recent_messages = @chat_session.messages.order(:created_at).last(2).map do |m|
      { role: m.role, content: m.content }
    end

    summaries + recent_messages
  end
end
