# ExceptionNotification::Ikachan

ExceptionNotification plugin for Ikachan!!!

[![wercker status](https://app.wercker.com/status/6e059ec136a619b280a4f5b05e4a685b/m "wercker status")](https://app.wercker.com/project/bykey/6e059ec136a619b280a4f5b05e4a685b)

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

### Message modifiers

* `:message_prefix` - Adds prefix to default format
* `:message_suffix` - Adds suffix to default format
* `:message_nocolor` - Decolorize the format

## Keys available in `:message_format`

* `%{class}` - Exception class
* `%{messgae}` - Exception message
* `%{occurred}` - A line that the exception is first thrown (`exception.backtrace.first`)

### Request keys

Nofitier can notify the information via web requests.
Keys named like `'%{request_path_info}', %{request_url}'` will be
converted to descriptions from `request.path_info, request.url`, and so on.

`request` should be an instance of `ActionDispatch::Request` (Rails) or `Rack::Request` (Other Rack apps)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
