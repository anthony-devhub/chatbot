class Users::RegistrationsController < ActionController::API
  def create
    user = User.new(sign_up_params)
    if user.save
      render json: { message: "Signed up successfully.", user: user }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
