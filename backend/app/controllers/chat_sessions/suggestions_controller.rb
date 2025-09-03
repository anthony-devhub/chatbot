class ChatSessions::SuggestionsController < ApplicationController
  before_action :set_chat_session

  def index
    partial_content = params[:partial_content].to_s.strip

    if partial_content.blank?
      return render json: { error: "partial_content is required" }, status: :unprocessable_entity
    end

    # Call a service object to generate suggestions
    # service = OpenRouterService.new(messages: prompt, tone: params[:tone])
    # ai_response_text = service.call
    generator = SuggestionGenerator.new(
      chat_session: @chat_session,
      partial_content: partial_content
    )
    suggestions = generator.call

    render json: { suggestions: suggestions }, status: :ok
  end

  private

  def set_chat_session
    @chat_session = current_user.chat_sessions.find(params[:chat_session_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Chat session not found" }, status: :not_found
  end
end
