# Shreddies - Stupid simple Rails model and object serializer

Shreddies is a JSON serialization library for Rails that focuses on simplicity and speed. No more "magic" DSL's - just plain old Ruby objects! It's primarily intended to serialize Rails models as JSON, but will also work with pretty much anything at all.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shreddies'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install shreddies

## Usage

Serializers should be named after your models and located in "`app/serializers`". Any public methods you define will be serialized, and you can quickly expose methods from the serialized subject using the `delegate` class method, which simply delegates to the subject.

```ruby
# app/serializers/user_serializer.rb
class UserSerializer < Shreddies::Json
  delegate :id, :first_name, :last_name, :email

  def name
    "#{first_name} #{last_name}"
  end
end
```

Calling the above will result in this JSON:

```json
{
  "id": 1,
  "name": "Joel Moss",
  "firstName": "Joel",
  "lastName": "Moss",
  "email": "me@you.com"
}
```

> **NOTE** that all keys are transformed to camelCase, as the JSON is intended to be used by Javascript.

Call your serializer directly:

```ruby
UserSerializer.render(user)
```

Or just use the `#as_json` instance method on your model:

```ruby
User.find(1).as_json
```

Model collections and array's are also supported:

```ruby
User.all.as_json
```

### Collection and Single Modules

You may find that you don't want or need to return as much data in collections of objects, or may want to include differtent data. So if a serializer defines a `Collection` module, and a collection or array is being rendered, then that Collection module will automatically be included:

```ruby
ArticleSerializer < Shreddies::Json
  module Collection
    def url
      "https://blah.com/#{subject.slug}"
    end
  end
end
```

Conversely, you can define a `Single` module, and that will be included when rendering a single object.

```ruby
ArticleSerializer < Shreddies::Json
  module Single
    def body
      'this body is really, really long, and I do not want it returned in lists.'
    end
  end
end
```

### `before_render` callback

You can define a `#before_render` private method in your serializers, which will act as a callback. It receives the object to be output, and expects you to return the object, which allows you to modify it before rendering.

### Options

Both `#as_json` and `.render` accepts an `options` hash, which will be forwarded to the serializer class, and available as `options`. This allows you to pass arbitrary options and use them in your serializer.

The following standard options are supported, and provide additional built-in functionality:

#### `serializer`

By default `#as_json` will look for a serializer named after your model. So a `User` model will automatically use the `UserSerializer`. Sometimes you want to use a different serializer class, in which case you can use the `serializer` option:

```ruby
User.all.as_json serializer: User::AdminSerializer
```

#### `module`

You can pass one or module names in the `module` option, and these modules will be included into the serializer. This is great for selectively including attributes and methods.

```ruby
Article.all.as_json module: :WithBody
```

```ruby
ArticleSerializer < Shreddies::Json
  module WithBody
    def body
      'This article body is really, really long'
    end
  end
end
```

The `Collection` and `Single` modules can be defined and they will be automatically included. The Collection module will be included when rendering an array or ActiveRecord collection (`ActiveRecord::Relation`), and the Single module will be included when rendering a single obejct.

#### `transform_keys` (default: true)

If false, the returned keys will not be transformed. The default is to deeply transform all keys to camelCase.

#### `index_by`

Give this option a property of your serialized subject as a Symbol, and the returned collection will be a Hash keyed by that property.

```ruby
User.all.as_json index_by: :id
```

```json
{
  1: {
    "id": 1,
    "name": "Joel Moss",
    "firstName": "Joel",
    "lastName": "Moss"
  }

  2: {
    "id": 2,
    "name": "An Other",
    "firstName": "An",
    "lastName": "Other"
  }

  ...
}
```

### Serializer Inheritance

A serializer can inherit from any other serializer, which is a great way to create custom views:

```ruby
# app/serializers/user_serializer.rb
class UserSerializer < Shreddies::Json
  delegate :id, :first_name, :last_name, :email

  def name
    "#{first_name} #{last_name}"
  end
end

class User::AdministratorSerializer < UserSerializer
  def type
    'administrator'
  end
end
```

Then call it like any other serializer:

```ruby
User::AdministratorSerializer.render(user)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joelmoss/shreddies. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/joelmoss/shreddies/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shreddies project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joelmoss/shreddies/blob/master/CODE_OF_CONDUCT.md).
