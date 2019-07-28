# frozen_string_literal: true

require 'base64'

class AuthToken < ApplicationRecord
  has_secure_token :key

  belongs_to :user

  class << self
    def find_by_header(value)
      decoded_value = nil

      begin
        decoded_value = Base64.urlsafe_decode64(value)
      rescue ArgumentError
        return nil
      end

      parts = nil

      begin
        parts = JSON.parse(decoded_value)
      rescue TypeError, JSON::ParserError
        return nil
      end

      return nil unless parts.is_a?(Hash)

      begin
        user_id = parts.fetch('uid')
        token_id = parts.fetch('tid')
        token_key = parts.fetch('k')
      rescue KeyError
        return nil
      end

      find_by(id: token_id, user_id: user_id, key: token_key)
    end
  end

  def for_header
    Base64.urlsafe_encode64(
      {
        'uid' => user_id,
        'tid' => id,
        'k' => key,
      }.to_json
    )
  end
end
