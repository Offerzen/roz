class API::BaseController < ApplicationController
  before_action :authenticate

  def authenticate
    # find user by token in auth
    # raise error if no current user
    # @current_user = ...
  end
end
