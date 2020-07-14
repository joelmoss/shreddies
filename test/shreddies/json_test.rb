# frozen_string_literal: true

require 'test_helper'

class Shreddies::JsonTest < Minitest::Test
  def setup
    User.delete_all
  end

  def test_render_a_single_plain_ruby_object
    expect = { 'name' => 'Joel Moss' }
    assert_equal expect, MyUserSerializer.render(first_name: 'Joel', last_name: 'Moss')
  end

  def test_render_a_single_active_record
    user = User.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')

    assert_equal({ 'name' => 'Joel Moss', 'email' => 'joel@moss.com' }, UserSerializer.render(user))
  end

  def test_render_namespaced_serializer
    user = User::Admin.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')

    assert_equal({ 'adminTeam' => 'devs', 'name' => 'Joel Moss', 'email' => 'joel@moss.com' },
                 User::AdminSerializer.render(user))
    end

  def test_render_deep_namespaced_serializer
    user = User::Admin.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')

    assert_equal({ 'adminTeam' => 'bots', 'name' => 'Joel Moss', 'email' => 'joel@moss.com' },
                 User::Admin::BotSerializer.render(user))
    end

  def test_render_an_array
    data = [
      { first_name: 'Joel', last_name: 'Moss' },
      { first_name: 'Joel2', last_name: 'Moss2' }
    ]

    assert_equal [{ 'name' => 'Joel Moss' }, { 'name' => 'Joel2 Moss2' }],
                 MyUserSerializer.render(data)
  end

  def test_auto_render_single_module
    data = Article.create(title: 'Article One')

    assert_equal({ 'body' => 'A really, really long body for Article One',
                   'title' => 'Article One' },
                 ArticleSerializer.render(data))
  end

  def test_auto_render_inherited_single_modules
    data = Article.create(title: 'Article One')

    assert_equal({ 'body' => 'A really, really long body for Article One',
                   'title' => 'Article One' },
                 Article::VideoSerializer.render(data))
  end

  def test_auto_render_own_and_inherited_single_modules
    data = Article.create(title: 'Article One')

    assert_equal({ 'body' => 'body!',
                   'title' => 'Article One', 'bodyAsHtml' => 'body as html' },
                 Article::DocumentSerializer.render(data))
  end

  def test_auto_render_collection_module
    data = Article.create([{ title: 'Article One' }, { title: 'Article Two' }])

    assert_equal [{ 'slug' => 'article-one', 'title' => 'Article One' },
                  { 'slug' => 'article-two', 'title' => 'Article Two' }],
                 ArticleSerializer.render(data)
  end

  def test_render_module
    data = Article.create(title: 'Article One', subtitle: 'My subtitle')

    assert_equal({ 'body' => 'Some body for Article One', 'title' => 'Article One',
                   'subtitle' => 'My subtitle' },
                 ArticleSerializer.render(data, module: :WithBody))
  end

  def test_render_explicit_module
    data = Article.create(title: 'Article One', subtitle: 'My subtitle')

    assert_equal({ 'body' => 'explicit body', 'title' => 'Article One' },
                 ArticleSerializer.render(data, module: ExplicitBody))
  end

  def test_render_several_modules
    data = Article.create(title: 'Article One', subtitle: 'My subtitle')
    expected = { 'body' => 'Adjusted body for Article One', 'url' => 'http://blah/article-one',
                 'title' => 'Article One', 'subtitle' => 'My subtitle' }

    assert_equal(expected, ArticleSerializer.render(data, module: %i[WithBody WithUrl]))
  end

  def test_render_an_array_with_index_by_option
    data = [
      { first_name: 'Joel', last_name: 'Moss' },
      { first_name: 'Joel2', last_name: 'Moss2' }
    ]

    assert_equal({ 'Joel' => { 'name' => 'Joel Moss' }, 'Joel2' => { 'name' => 'Joel2 Moss2' } },
                 MyUserSerializer.render(data, index_by: :first_name))
  end

  def test_render_a_collection_of_records
    User.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')
    User.create(first_name: 'Joel2', last_name: 'Moss2', email: 'joel2@moss2.com')

    expect = [{ 'name' => 'Joel Moss', 'email' => 'joel@moss.com' },
              { 'name' => 'Joel2 Moss2', 'email' => 'joel2@moss2.com' }]
    assert_equal expect, UserSerializer.render(User.all)
  end

  def test_render_a_collection_of_records_with_index_by_option
    User.create(first_name: 'Joel', last_name: 'Moss', email: 'joel@moss.com')
    User.create(first_name: 'Joel2', last_name: 'Moss2', email: 'joel2@moss2.com')

    expect = { 'Joel' => { 'name' => 'Joel Moss', 'email' => 'joel@moss.com' },
               'Joel2' => { 'name' => 'Joel2 Moss2', 'email' => 'joel2@moss2.com' } }
    assert_equal expect, UserSerializer.render(User.all, index_by: :first_name)
  end
end
