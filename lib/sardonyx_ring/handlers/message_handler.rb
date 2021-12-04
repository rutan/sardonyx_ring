# frozen_string_literal: true

module SardonyxRing
  module Handlers
    class MessageHandler
      def initialize(pattern, callback)
        @pattern = pattern
        @callback = callback
      end

      attr_reader :pattern

      def run(app, message_event, match = nil)
        args = [message_event, match].slice(0, @callback.arity)
        @callback.bind(app).call(*args)
      end

      def match(message)
        case @pattern
        when String
          @pattern if message.text == @pattern
        when Regexp
          message.text&.match(@pattern)
        end
      end
    end
  end
end
