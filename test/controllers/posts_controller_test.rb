require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "cannot create post if not authenticated" do
    assert_no_difference('Post.count') do
      post posts_url, params: { content: 'My old bike' }
    end

    assert_response :unauthorized
  end

  test "should create post" do
    assert_difference('Post.count') do
      post posts_url, params: { content: 'My old bike' }, headers: { 'Authorization' => "Token #{auth_token_header}" }
    end

    assert_response :success
  end

  test "should show post" do
    get post_url(a_post)
    assert_response :success
  end

  test "cannot destroy post if not authenticated" do
    post = create_a_post!

    assert_no_difference('Post.count') do
      delete post_url(post)
    end

    assert_response :unauthorized
  end

  test "cannot destroy post if not authorized" do
    post = create_a_post!

    assert_not_equal post.user, a_user

    assert_raises('ActiveRecord::RecordNotFound') do
      assert_no_difference('Post.count') do
        delete post_url(post), headers: { 'Authorization' => "Token #{auth_token_header}" }
      end
    end
  end

  test "should destroy post" do
    post = create_a_post!
    post.update!(user: a_user)

    assert_equal post.user, a_user

    assert_difference('Post.count', -1) do
      delete post_url(post), headers: { 'Authorization' => "Token #{auth_token_header}" }
    end

    assert_response :success
  end

  private

  def create_a_post!
    a_post
  end

  def a_post
    @a_post ||= Post.new(content: 'A book', address: 'Some Place') do |post|
      post.build_user(first_name: 'Recep', last_name: 'Toy')
      post.save!
      post.images.create!(cloudinary_public_id: 'fake_id_of_img1', uploaded_by: post.user)
    end
  end

  def a_user
    @a_user ||= User.create!(first_name: 'Cemal', last_name: 'Toy')
  end

  def auth_token_header
    @auth_token_header ||= begin
      a_user.create_auth_token!
      a_user.auth_token.for_header
    end
  end
end
