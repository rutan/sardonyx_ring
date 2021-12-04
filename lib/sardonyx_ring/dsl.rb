# frozen_string_literal: true

module SardonyxRing
  module DSL
    def self.included(base)
      base.extend(ClassMethods)
    end

    def action_handlers
      self.class.action_handlers
    end

    def message_handlers
      self.class.message_handlers
    end

    def event_handlers
      self.class.event_handlers
    end

    def view_handlers
      self.class.view_handlers
    end

    def cron_handlers
      self.class.cron_handlers
    end

    module ClassMethods
      def action_handlers
        @action_handlers ||= []
      end

      def message_handlers
        @message_handlers ||= []
      end

      def event_handlers
        @event_handlers ||= []
      end

      def view_handlers
        @view_handlers ||= []
      end

      def cron_handlers
        @cron_handlers ||= []
      end

      def message(pattern, &block)
        message_handlers.push Handlers::MessageHandler.new(
          pattern,
          create_handler_method(&block)
        )
      end

      alias on message

      def action(event_name, &block)
        action_handlers.push Handlers::ActionHandler.new(
          event_name,
          create_handler_method(&block)
        )
      end

      def view(callback_id, &block)
        view_handlers.push Handlers::ViewHandler.new(
          callback_id,
          create_handler_method(&block)
        )
      end

      def event(event_name, &block)
        event_handlers.push Handlers::EventHandler.new(
          event_name,
          create_handler_method(&block)
        )
      end

      def every(cron_format, &block)
        cron_handlers.push Handlers::CronHandler.new(
          cron_format,
          create_handler_method(&block)
        )
      end

      private

      def create_handler_method(&block)
        tmp_name = :__tmp_handler_method
        define_method(tmp_name, &block)
        created_method = instance_method(tmp_name)
        remove_method(tmp_name)
        created_method
      end
    end
  end
end
