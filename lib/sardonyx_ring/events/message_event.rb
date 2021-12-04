# frozen_string_literal: true

module SardonyxRing
  module Events
    class MessageEvent
      def initialize(raw_payload)
        @raw_payload = raw_payload
      end

      attr_reader :raw_payload

      def say(params = {})
        return unless @say_handler

        @say_handler.call(self, params)
      end

      def register_say_handler(callback)
        @say_handler = callback
      end

      def respond_to_missing?(symbol, include_private)
        return true if raw_payload.event.respond_to?(symbol)

        super
      end

      def method_missing(method, *args)
        return raw_payload.event.send(method, *args) if raw_payload.event.respond_to?(method)

        super
      end
    end
  end
end
