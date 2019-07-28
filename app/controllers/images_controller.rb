# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :authenticate!

  def create
    @image = PostImage.new(uploaded_by: current_user, uploaded_file: params[:image])

    respond_to do |format|
      if @image.save
        format.json { render :create, status: :created }
      else
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end
end
