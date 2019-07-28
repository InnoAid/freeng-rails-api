json.array! @search_results do |search_result|
  json.partial! "posts/post", post: search_result.record
end
