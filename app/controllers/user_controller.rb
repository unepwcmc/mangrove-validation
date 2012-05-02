class UserController < ApplicationController
  respond_to :json

  def me
    if user_signed_in?
      respond_with current_user.to_json(only: [:id, :email])
    else
      render text: '401 Unauthorized', :status => :unauthorized
    end
  end
end