# frozen_string_literal: true

require 'test_helper'

class Shreddies::AsJsonTest < Minitest::Test
  def setup
    User.delete_all
  end

  def test_as_json
    user = User.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')

    assert_equal({ 'name' => 'Joel Moss', 'email' => 'joel@moss.com' }, user.as_json)
  end

  def test_as_json_with_no_serializer
    post = Post.create(title: 'My blog post')

    assert_equal({ 'id' => post.id, 'title' => 'My blog post' }, post.as_json)
  end

  def test_as_json_with_serializer_option
    user = User.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')

    assert_equal({ 'name' => 'Joel Moss' }, user.as_json(serializer: MyUserSerializer))
  end

  def test_active_record_relation_as_json
    User.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')
    User.create(first_name: 'Joel2', last_name: 'Moss2', email: 'joel2@moss2.com')

    expect = [{ 'name' => 'Joel Moss', 'email' => 'joel@moss.com' },
              { 'name' => 'Joel2 Moss2', 'email' => 'joel2@moss2.com' }]
    assert_equal expect, User.all.as_json
  end
end
