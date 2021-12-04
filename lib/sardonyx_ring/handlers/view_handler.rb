# frozen_string_literal: true

module SardonyxRing
  module Handlers
    class ViewHandler
      def initialize(callback_id, callback)
        @callback_id = callback_id
        @callback = callback
      end

      attr_reader :callback_id

      def run(app, view_event)
        args = [view_event].slice(0, @callback.arity)
        @callback.bind(app).call(*args)
      end

      def match?(view_event)
        @callback_id == view_event.callback_id
      end
    end
  end
end
