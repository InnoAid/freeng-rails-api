# frozen_string_literal: true

class AuthenticationController < ApplicationController
  def login
    user = nil

    if params[:access_token] && params[:backend] == 'facebook'
      user = User.authenticate_with_facebook!(params[:access_token])
    else
      raise
    end

    render json: {
      token: user.token_for_header,
      userid: user.id,
    }
  end
end
