json.id image.id
json.image cl_image_path(image.cloudinary_public_id, width: 400, height: 400, crop: :fill)
json.image_thumbnail_large cl_image_path(image.cloudinary_public_id, width: 400, height: 400, crop: :fill)
json.image_gallery cl_image_path(image.cloudinary_public_id, width: 400, height: 400, crop: :fill)
