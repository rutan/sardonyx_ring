# frozen_string_literal: true

module SardonyxRing
  module Handlers
    class ActionHandler
      def initialize(action_id, callback)
        @action_id = action_id
        @callback = callback
      end

      attr_reader :action_id

      def run(app, action_event)
        args = [action_event].slice(0, @callback.arity)
        @callback.bind(app).call(*args)
      end

      def match?(action_event)
        @action_id == action_event.current_action.action_id
      end
    end
  end
end
