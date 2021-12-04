# frozen_string_literal: true

module SardonyxRing
  module Events
    class ViewEvent
      def initialize(raw_payload)
        @raw_payload = raw_payload
      end

      attr_reader :raw_payload

      def respond_to_missing?(symbol, include_private)
        return true if raw_payload.view.respond_to?(symbol)

        super
      end

      def method_missing(method, *args)
        return raw_payload.view.send(method, *args) if raw_payload.view.respond_to?(method)

        super
      end
    end
  end
end
