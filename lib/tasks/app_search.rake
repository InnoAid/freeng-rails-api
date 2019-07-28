namespace :app_search do
  desc "Import posts to App Search"
  task import: :environment do
    begin
      Post.swiftype_app_search_client.get_engine(Post.swiftype_app_search_engine_name)
    rescue SwiftypeAppSearch::NonExistentRecord
      puts "Create engine..."
      Post.swiftype_app_search_client.create_engine(Post.swiftype_app_search_engine_name)
      sleep 5
    end

    puts "Index documents..."
    Post.all.find_in_batches(batch_size: 100) do |group|
      Post.swiftype_app_search_client.index_documents(Post.swiftype_app_search_engine_name, group.map(&:document_for_app_search))
    end

    puts "Update schema..."
    Post.swiftype_app_search_client.post("engines/#{Post.swiftype_app_search_engine_name}/schema", Post.swiftype_app_search_schema)
  end
end
