# frozen_string_literal: true

class PostImage < ApplicationRecord
  class << self
    def upload_to_cloudinary_folder
      if Rails.env.test?
        nil
      elsif Rails.env.production?
        ENV.fetch('UPLOAD_TO_CLOUDINARY_FOLDER', 'production')
      else
        ENV.fetch('UPLOAD_TO_CLOUDINARY_FOLDER', "development-#{ENV.fetch('USER')}")
      end
    end
  end

  delegate :upload_to_cloudinary_folder, to: :class

  belongs_to :uploaded_by, class_name: 'User'
  belongs_to :post, optional: true

  attr_accessor :uploaded_file

  before_create :upload_to_cloudinary
  after_destroy_commit :delete_from_cloudinary

  private

  def upload_to_cloudinary
    return if Rails.env.test?
    return if uploaded_file.blank? || cloudinary_public_id.present?

    upload_response = Cloudinary::Uploader.upload(uploaded_file, folder: upload_to_cloudinary_folder)
    self.cloudinary_public_id = upload_response.fetch('public_id')
  end

  def delete_from_cloudinary
    return if Rails.env.test?

    delete_response = Cloudinary::Uploader.destroy(cloudinary_public_id)
    raise 'Could not delete from Cloudinary' if delete_response.fetch('result') != 'ok'
  end
end
