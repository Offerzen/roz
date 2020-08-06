class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!

  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.find_by(email: auth["info"]["email"])

    raise "No such user!" unless @user

    sign_in_and_redirect(@user)
  end
end
