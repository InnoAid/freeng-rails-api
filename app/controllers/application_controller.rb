# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include CloudinaryHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate

  private

  def authenticate!
    authenticate
    return if authenticated?

    respond_to do |format|
      format.json { head :unauthorized }
    end
  end

  def authenticate
    return @current_auth_token if defined?(@current_auth_token)
    return if request.headers['Authorization'].blank?

    header_value = request.headers['Authorization'].to_s.sub(/\AToken /, '')
    @current_auth_token = AuthToken.find_by_header(header_value)
  end

  def authenticated?
    !!@current_auth_token
  end

  def current_user
    @current_auth_token&.user
  end
end
