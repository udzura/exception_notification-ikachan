require "spec_helper"

describe ExceptionNotifier::IkachanNotifier do
  let(:notifier) { ExceptionNotifier::IkachanNotifier.new(options) }

  describe "initial options" do
    let(:options) do
      {
        base_url: 'ikachan.udzura.jp',
        channel:  '#udzura',
        message_format: '%{class}: %{message}'
      }
    end

    describe ":base_url" do
      it "should set client's base_url" do
        expect(notifier.client.base_url).to eq("http://ikachan.udzura.jp/")
      end
    end

    describe "message with invalid request key" do
      let(:options) do
        {
          base_url: 'ikachan.udzura.jp',
          channel:  '#udzura',
          message_format: '%{request_noattr}'
        }
      end

      it "should just raise error" do
        expect {
          notifier
        }.to raise_error(RuntimeError, "Parameter name request_noattr is unavailable")
      end
    end
  end

  describe "#build_message and #message" do
    before do
      require 'rack/request'
      stub_request(:post, "http://ikachan.udzura.jp/join")
      stub_request(:post, "http://ikachan.udzura.jp/notice")
    end
    let(:exception) { StandardError.new("Hello, exception!")}

    describe "message with request info" do
      let(:options) do
        {
          base_url: 'ikachan.udzura.jp',
          channel:  '#udzura',
          message_format: '%{request_path_info}'
        }
      end

      it "should include request's path info" do
        notifier.build_message(exception, {env: {'PATH_INFO' => '/foo/bar'}})
        expect(notifier.message).to eq("/foo/bar")
      end
    end

  end

  describe "#call" do
    let(:options) do
      {
        base_url: 'ikachan.udzura.jp',
        channel:  '#udzura',
        message_format: '%{class}: %{message}'
      }
    end
    let(:exception) { StandardError.new("Hello, exception!")}

    it "should notice message to ikachan" do
      stub_join = stub_request(:post, "http://ikachan.udzura.jp/join").
        with(body: {"channel" => "#udzura"})
      stub_notice = stub_request(:post, "http://ikachan.udzura.jp/notice").
        with(body: {"channel" => "#udzura", "message" => "StandardError: Hello, exception!"})

      notifier.call(exception, {})
      stub_join.should have_been_requested.once
      stub_notice.should have_been_requested.once
    end
  end
end
