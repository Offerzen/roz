class AdminController < ApplicationController
  before_action :authorize_user!

  def index
  end

  private

  def authorize_user!
    raise Pundit::NotAuthorizedError, "Must be admin" unless current_user.admin?
  end
end
