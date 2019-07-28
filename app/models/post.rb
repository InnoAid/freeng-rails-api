# frozen_string_literal: true

class Post < ApplicationRecord
  include SwiftypeAppSearchable

  belongs_to :user
  has_many :images, class_name: 'PostImage', dependent: :destroy

  before_save :reverse_geocode_to_fetch_location_info

  def location
    "#{latitude},#{longitude}"
  end

  alias latlng location

  def google_maps_geocoding_env
    if Rails.env.test?
      nil
    elsif Rails.env.production?
      :production
    else
      :non_production
    end
  end

  private

  def reverse_geocode_to_fetch_location_info
    return if Rails.env.test?

    uri = URI('https://maps.googleapis.com/maps/api/geocode/json')
    uri.query = URI.encode_www_form(
      latlng: latlng,
      result_type: 'country|administrative_area_level_1|administrative_area_level_2',
      key: Rails.application.credentials.google_maps_geocoding.dig(google_maps_geocoding_env, :key),
    )
    res = Net::HTTP.get_response(uri)
    res.value

    json_res = JSON.parse(res.body)
    address_components = json_res.dig('results', 0, 'address_components')
    return if address_components.blank?

    self.city = address_components.find { |component| component['types'].include?('administrative_area_level_1') || component['types'].include?('administrative_area_level_2') }&.fetch('long_name')
    self.country = address_components.find { |component| component['types'].include?('country') }&.fetch('long_name')
  end
end
