json.id post.id
json.content post.content
json.address post.address
json.city post.city
json.country post.country
json.date_created post.created_at
json.location do
  json.coordinates [post.latitude, post.longitude]
end

json.user do
  json.id post.user.id
  json.facebook_uid post.user.facebook_uid
  json.first_name post.user.first_name
  json.last_name post.user.last_name
  json.email post.user.email
end

json.images post.images do |image|
  json.partial! "posts/image", image: image
end
