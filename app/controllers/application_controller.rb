class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit

  rescue_from Pundit::NotAuthorizedError do
    head status: :forbidden
  end

  protect_from_forgery with: :exception

protected

  def authenticate_user!(args = {})
    if user_signed_in?
      super(args)
    else
      redirect_to new_user_session_path
    end
  end
end
