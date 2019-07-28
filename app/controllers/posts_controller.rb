# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate!, only: %i[create update destroy]

  def index
    search_options = {}.tap do |options|
      if params[:lat] && params[:lon] && params[:distance]
        options[:filters] = {
          location: {
            center: "#{params[:lat]},#{params[:lon]}",
            distance: Integer(params[:distance]),
            unit: 'km',
          }
        }
      end

      if params[:query].blank?
        options[:sort] = { created_at: :desc }
      end
    end
    @search_results = Post.swiftype_app_search_search_results(params[:query].to_s, search_options)

    respond_to do |format|
      format.json
    end
  end

  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.json
    end
  end

  def create
    @post = current_user.posts.new(content: params[:content], address: params[:content])
    @post.latitude, @post.longitude = params.dig(:location, :coordinates) if params.dig(:location, :type) == 'point'
    @post.image_ids = PostImage.where(post_id: nil, uploaded_by: current_user, id: params[:image_ids]).pluck(:id) if params[:image_ids]

    respond_to do |format|
      if @post.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
