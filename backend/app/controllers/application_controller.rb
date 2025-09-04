class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    return render json: { error: "Unauthorized" }, status: :unauthorized unless token

    begin
      payload = JwtService.decode(token)
      @current_user = User.find(payload["sub"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def call_ai(messages:, tone: nil)
    OpenRouterService.new(messages: messages, tone: tone).call
  end

  def summarize_messages(messages)
    prompt = [
      { role: "system", content: "Summarize the following chat into a concise, neutral summary. Only include details explicitly stated by the participants. Avoid adding external concepts or assumptions." }
    ] + messages

    call_ai(messages: prompt, tone: "neutral")
  end
end
