# ExceptionNotification::Ikachan

ExceptionNotification  plugin for Ikachan!!!

## Installation

Add this line to your application's Gemfile:

    gem 'exception_notification-ikachan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exception_notification-ikachan

## Usage

```ruby
FooBar::Application.configure do
  config.middleware.use ExceptionNotification::Rack,
    ikachan: {
      channel: '#udzura',
      base_url: 'ikachan.example.com:8080'
    }
end
```

`:message_format` like `"%{class}: %{message}"` also available.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
