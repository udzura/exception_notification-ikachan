require "exception_notification/ikachan/version"
require 'net/http'

module ExceptionNotification
  class Ikachan
    class Client
      def initialize(base_url)
        @base_url = base_url.match(/^https?:\/\/[^\/]+\//) ? base_url : "http://#{base_url}/"
      end
      attr_reader :base_url

      def notice_all(channels, message)
        channels.each do |channel|
          join(channel)
          notice(channel, message)
        end
      end

      private
      def join(channel)
        dispatch :join, 'channel' => channel
      end

      def notice(channel, message)
        dispatch :notice, 'channel' => channel, 'message' => message
      end

      def dispatch(type, params = {})
        uri = URI.parse "#{base_url}#{type.to_s}"
        Net::HTTP.post_form uri, params
      end
    end

    def initialize(options)
      channel = options[:channels] || options[:channel]
      if !channel or !options[:base_url]
        raise "Some of option is missing: %s" % options
      end

      @channels = channel.is_a?(Array) ? channel : [channel]
      @client   = Client.new(options[:base_url])
      @message_format = build_message_format(options)
    end
    attr_reader :client, :channels, :message_format

    def call(exception, options = {})
      client.notice_all(channels, build_message(exception))
    end

    private
    def build_message_format(options)
      return options[:message_format] if options[:message_format]
      "\x02\x0315,4[ERROR]\x03 \x0313%{class}\x03 - \x038%{message}\x03, %{occurred}\x0f"
    end

    def build_message(exception)
      params = {
        class:    exception.class,
        message:  exception.message,
        occurred: (exception.backtrace.first rescue nil),
      }
      return message_format % params
    end
  end
end

module ExceptionNotifier
  IkachanNotifier = ExceptionNotification::Ikachan
end
