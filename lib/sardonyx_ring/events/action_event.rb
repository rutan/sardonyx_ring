# frozen_string_literal: true

module SardonyxRing
  module Events
    class ActionEvent
      def initialize(raw_payload, current_action)
        @raw_payload = raw_payload
        @current_action = current_action
      end

      attr_reader :raw_payload, :current_action

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
