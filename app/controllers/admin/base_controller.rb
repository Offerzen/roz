class Admin::BaseController < ApplicationController
  include Pundit

  before_action :authorize_admin
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout 'admin'

  def authorize_admin
    authorize current_user, policy_class: AdminPolicy
  end

  def user_not_authorized
    redirect_to root_path, flash: { error: "You are not authorized to view this page" }
  end
end
