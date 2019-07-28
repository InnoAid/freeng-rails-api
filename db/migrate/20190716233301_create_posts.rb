class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.timestamps null: false

      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :facebook_uid
    end

    create_table :auth_tokens do |t|
      t.timestamps null: false

      t.belongs_to :user, null: false
      t.string :key, null: false
    end

    create_table :posts do |t|
      t.timestamps null: false

      t.belongs_to :user, null: false
      t.text :content
      t.text :address
      t.string :longitude
      t.string :latitude
      t.string :city
      t.string :country
    end

    create_table :post_images do |t|
      t.timestamps null: false

      t.belongs_to :uploaded_by
      t.belongs_to :post
      t.string :cloudinary_public_id, null: false
    end
  end
end
