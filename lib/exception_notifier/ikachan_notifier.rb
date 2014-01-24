require "exception_notification/ikachan/version"
require 'net/http'

module ExceptionNotifier
  class IkachanNotifier
    class Client
      def initialize(base_url)
        @base_url = base_url.match(/^https?:\/\/[^\/]+\//) ? base_url : "http://#{base_url}/"
      end
      attr_reader :base_url

      def notice_all(channels, message)
        channels.each do |channel|
          join(channel)
          message.each_line do |line|
            notice(channel, line)
          end
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
      @message  = nil

      @request_param_names = message_format.scan(/%{(request_[a-zA-Z_?!]+)}/).flatten.uniq
      @request_param_names.map{|n| [n, n.sub(/^request_/, '')] }.each do |param_name, attribute|
        raise "Parameter name #{param_name} is unavailable" unless request_klass.method_defined?(attribute)
      end
    end
    attr_reader :client, :channels, :message_format, :message
    DEFAULT_FORMAT = "\x02\x0315,4[ERROR]\x03 \x0313%{class}\x03 - %{message}\x03\x0f, %{occurred}"
    IRC_SEQUENCE_RE = Regexp.new("[\x02\x03\x0f](\\d+)?(,\\d+)?")

    def call(exception, options = {})
      build_message(exception, options)
      client.notice_all(channels, message)
    end

    def build_message(exception, options = {})
      params = {
        class:    exception.class,
        message:  exception.message,
        occurred: (exception.backtrace.first rescue nil),
      }
      params.merge!(build_params_from_request(options[:env]))
      @message = message_format % params
    end

    private
    def request_klass
      @request_klass ||= if defined?(ActionDispatch::Request)
        ActionDispatch::Request
      else
        require 'rack/request'
        Rack::Request
      end
    rescue LoadError, NameError
      raise "Please use this notifier in some kind of Rack-based webapp"
    end

    def build_message_format(options)
      return options[:message_format] if options[:message_format]
      DEFAULT_FORMAT.dup.tap do |fmt|
        fmt.prepend(options[:message_prefix]) if options[:message_prefix]
        fmt.concat(options[:message_suffix])  if options[:message_suffix]
        fmt.gsub!(IRC_SEQUENCE_RE, '')        if options[:message_nocolor]
      end
    end

    def build_params_from_request(env=nil)
      return default_params_from_request unless env
      request = request_klass.new(env)
      dest = {}
      @request_param_names.map{|n| [n, n.sub(/^request_/, '')] }.each do |param_name, attribute|
        dest[param_name.to_sym] = request.send(attribute)
      end
      dest
    end

    def default_params_from_request
      @request_param_names.each_with_object({}) do |name, dest|
        dest[name.to_sym] = ''
      end
    end

    # alias
    VERSION = ExceptionNotification::Ikachan::VERSION
  end
end
