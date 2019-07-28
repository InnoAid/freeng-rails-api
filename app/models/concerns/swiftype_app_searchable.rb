# frozen_string_literal: true

module SwiftypeAppSearchable
  extend ActiveSupport::Concern

  SearchResult = Struct.new(:hit, :record)

  included do
    cattr_accessor :_swiftype_app_search_client

    after_commit :put_on_app_search, on: %i[create update]
    after_commit :delete_from_app_search, on: [:destroy]
  end

  class_methods do
    def swiftype_app_search_env
      if Rails.env.test?
        nil
      elsif Rails.env.production?
        :production
      else
        :non_production
      end
    end

    def swiftype_app_search_client
      self._swiftype_app_search_client ||= SwiftypeAppSearch::Client.new(
        host_identifier: Rails.application.credentials.swiftype_app_search.dig(swiftype_app_search_env, :host_identifier),
        api_key: Rails.application.credentials.swiftype_app_search.dig(swiftype_app_search_env, :private_key),
      )
    end

    def swiftype_app_search_schema
      {
        content: 'text',
        created_at: 'date',
        location: 'geolocation',
      }
    end

    def swiftype_app_search_engine_name
      if Rails.env.test?
        nil
      elsif Rails.env.production?
        ENV.fetch('APP_SEARCH_ENGINE_NAME', 'freeng-production')
      else
        ENV.fetch('APP_SEARCH_ENGINE_NAME', "freeng-dev-#{ENV.fetch('USER')}")
      end
    end

    def swiftype_app_search_search_results(query, options = {})
      if Rails.env.test?
        return all.map { |post| SearchResult.new(nil, post) }
      end

      response = swiftype_app_search_client.search(swiftype_app_search_engine_name, query, options)
      results = response.fetch('results')
      post_ids = results.map { |result| result.dig('id', 'raw') }
      posts_map = all.where(id: post_ids).group_by { |post| String(post.id) }
      results.map do |result|
        post_id = String(result.dig('id', 'raw'))
        post = posts_map[post_id]&.first
        next if post.nil?

        SearchResult.new(result, post)
      end.compact
    end
  end

  delegate :swiftype_app_search_client, :swiftype_app_search_engine_name, to: :class

  def document_for_app_search
    slice(:id, :content, :location, :created_at)
  end

  private

  def put_on_app_search
    return if Rails.env.test?

    swiftype_app_search_client.index_documents(swiftype_app_search_engine_name, [document_for_app_search])
  end

  def delete_from_app_search
    return if Rails.env.test?

    swiftype_app_search_client.destroy_documents(swiftype_app_search_engine_name, [id])
  end
end
