json.id image.id
json.image cl_image_path(image.cloudinary_public_id, width: 1000, crop: :scale)

PostImage::VARIANTS.each do |name, options|
  json.set! "image_#{name}", cl_image_path(image.cloudinary_public_id, options)
end
