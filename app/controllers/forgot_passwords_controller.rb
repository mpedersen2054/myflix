class ForgotPasswordsController < ApplicationController
  def new

  end

  def create
    user = User.where(email: params[:email]).first
    if user
      AppMailer.send_forgot_password(user).deliver
      redirect_to forgot_password_confirmation_path
    else
      redirect_to forgot_password_path
      flash[:danger] = params[:email].blank? ? "Email cannot be blank." : "There is no user with that email in the system."
    end
  end

  def confirm
  end
end