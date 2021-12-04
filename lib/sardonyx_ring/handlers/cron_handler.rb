# frozen_string_literal: true

module SardonyxRing
  module Handlers
    class CronHandler
      def initialize(cron_format, callback)
        @cron_format = cron_format
        @callback = callback
      end

      attr_reader :cron_format

      def run(app)
        @callback.bind(app).call
      end

      def next_time(current_time = Time.now)
        cron.next(current_time)
      end

      private

      def cron
        @cron ||= CronParser.new(cron_format)
      end
    end
  end
end
