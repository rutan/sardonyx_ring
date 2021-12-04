# frozen_string_literal: true

module SardonyxRing
  module Services
    class SlackSocketClient
      SLACK_API_ORIGIN = 'https://slack.com'

      def initialize(options = {})
        @app_client = SlackAppClient.new(token: options[:token])
        @logger = options[:logger]
        @handler = nil
        @ws = nil
      end

      def on_message(&block)
        @handler = block
      end

      def connect!
        require 'faye/websocket'

        open_resp = @app_client.request('apps.connections.open')
        raise open_resp unless open_resp.ok

        url = "#{open_resp.url}#{debug? ? '&debug_reconnects=true' : ''}"

        @ws = Faye::WebSocket::Client.new(url)
        @ws.on(:open, &method(:on_ws_open))
        @ws.on(:message, &method(:on_ws_message))
        @ws.on(:close, &method(:on_ws_close))
      end

      private

      def debug?
        ENV['DEBUG'].to_i != 0
      end

      def on_ws_open(_event)
        @logger.info 'connect socket mode'
      end

      def on_ws_message(event)
        return unless @handler

        data = parse_response(event.data)
        @ws.send({ envelope_id: data.envelope_id }.to_json) if data.envelope_id

        case data.type
        when 'events_api', 'interactive'
          @handler.call(data.payload)
        when 'disconnect'
          @ws.close
        end
      end

      def on_ws_close(event)
        @logger.info "close socket mode (#{event.code}#{event.reason ? " / #{event.reason}" : ''})"
        connect!
      end

      def parse_response(response_body)
        JSON.parse(response_body, object_class: OpenStruct)
      end
    end
  end
end
