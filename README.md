# Houston::Releases

Generates Release Notes automatically from commit messages


## Installation

In your `Gemfile`, add:

    gem "houston-releases"

And in `config/main.rb`, add:

```ruby
use :releases do
  # TODO: specify configuration options for Houston::Releases here
end
```

And then execute:

    $ bundle


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
