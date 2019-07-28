# frozen_string_literal: true

class User < ApplicationRecord
  has_one :auth_token
  has_many :posts

  class << self
    def authenticate_with_facebook!(access_token)
      uri = URI('https://graph.facebook.com/v3.3/me')
      uri.query = URI.encode_www_form(access_token: access_token, fields: 'id,first_name,last_name')
      res = Net::HTTP.get_response(uri)
      res.value

      json_res = JSON.parse(res.body)

      transaction do
        user = find_or_initialize_by(facebook_uid: json_res['id'])
        user.first_name = json_res['first_name']
        user.last_name = json_res['last_name']
        user.save!

        user.create_auth_token! unless user.auth_token
        user
      end
    end
  end

  def token_for_header
    auth_token&.for_header
  end
end
