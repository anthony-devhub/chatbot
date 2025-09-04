class Users::SessionsController < ActionController::API
  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = JwtService.encode(sub: user.id, exp: 24.hours.from_now.to_i)
      render json: { token: token, user: { id: user.id, email: user.email } }, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    head :no_content
  end
end
