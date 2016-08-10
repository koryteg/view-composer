# ViewComposer

View Composer makes it easy to compose view objects for ruby apps. Create new composers, pass them a model and classes to merge, and all instance methods of the classes will be available on the composer. The Composer will also serialize these instance methods into `json` for an api. I like to think of it as a mix between Draper and Active Model Serializer but built on ideas of composition from Sandi Metz.

This is still pre 1.0 software and the api will change.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'view_composer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install view_composer

## Usage

create a new composer that inherits from `BaseComposer`. and use the attributes api (similar to active model serializer) to let your composer know what methods to respond to.

``` ruby
class PostComposer < BaseComposer
    attributes :id, :name, :body
end

post_composer = PostCompser.new(model: Post.new(name: "a post") )
post_composer.name #=> "a post"
post_composer.id #=> 1
post_composer.hash_attrs #=> {id: 1, name: "a post", body: nil}
post_composer.to_json #=> "{\"id\":\"1\",\"name\":\"a post\", \"body\": \"\"}"
```

if you would like to override the model's value you can define it as a method

``` ruby
class PostComposer < BaseComposer
    attributes :id, :name, :body
    
    def name
        "special super #{@model.name}"
    end
end
post_composer.name #=> special super a post
```

the last part of this (that really makes it a composer) is that you can pass other classes to the composer and it will define those methods on the composer and serialize them into the same json object as well. Say you have `AdminStats` for your post that takes an instance of a post and responds to `total_reads` and `referrers`. ie: `AdminStats.new(post).total_reads` returns `1000`.

your composer would look like this: 
``` ruby
post_composer = PostComposer.new(model: post, composable_objects: [AdminStats])
post_composer.total_reads #=> 1000
post_composer.referrers #=> ["bily", "bob", "jane"]
post_composer.to_json #=> {"id": "1", "name": "a post", "body": "", "total_reads": "1000", "referrers": ["bily", "bob", "jane"] }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ViewComposer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

