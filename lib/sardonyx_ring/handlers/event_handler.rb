# frozen_string_literal: true

module SardonyxRing
  module Handlers
    class EventHandler
      def initialize(event_name, callback)
        @event_name = event_name
        @callback = callback
      end

      attr_reader :event_name

      def run(app, event)
        args = [event].slice(0, @callback.arity)
        @callback.bind(app).call(*args)
      end

      def match?(general_event)
        @event_name == general_event.type
      end
    end
  end
end
