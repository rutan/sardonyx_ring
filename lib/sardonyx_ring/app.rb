# frozen_string_literal: true

module SardonyxRing
  class App
    include DSL

    def initialize(options = {})
      @app_token = options[:app_token]
      @bot_token = options[:bot_token]
      @bot_auth = nil
      @logger = options[:logger] || Logger.new($stdout, level: :info)
    end

    def client
      @client ||= Slack::Web::Client.new(token: @bot_token)
    end

    def socket_start!
      fetch_bot_auth

      EM.run do
        start_cron

        socket_client = Services::SlackSocketClient.new(
          token: @app_token,
          logger: @logger
        )
        socket_client.on_message(&method(:handle_event))
        socket_client.connect!
      end
    end

    private

    def start_cron
      cron_handlers.each do |handler|
        register_next_cron(handler)
      end
    end

    def register_next_cron(cron_handler)
      time = Time.now
      next_time = [(cron_handler.next_time(time) - time).ceil, 1].max
      EventMachine::Timer.new(next_time) do
        cron_handler.run(self)
        register_next_cron(cron_handler)
      end
    end

    def fetch_bot_auth
      resp = client.auth_test
      raise 'auth error' unless resp['ok']

      @bot_auth = OpenStruct.new(resp)
    end

    def handle_event(payload)
      case payload.type
      when 'block_actions'
        on_action(payload)
      when 'view_submission'
        on_view(payload)
      when 'event_callback'
        if payload.event.type == 'message'
          on_message(payload)
        else
          on_event(payload)
        end
      end
    end

    def on_action(payload)
      @logger.debug("action payload: #{payload}")

      payload.actions.each do |current_action|
        action_event = Events::ActionEvent.new(payload, current_action)

        action_handlers.each do |handler|
          next unless handler.match?(action_event)

          handler.run(self, action_event)
          break
        end
      end
    end

    def on_view(payload)
      @logger.debug("view payload: #{payload}")

      view_event = Events::ViewEvent.new(payload)

      view_handlers.each do |handler|
        next unless handler.match?(view_event)

        handler.run(self, view_event)
        break
      end
    end

    def on_message(payload)
      @logger.debug("message payload: #{payload}")

      return if payload.event.user == @bot_auth.user
      return if payload.event.bot_id

      message = Events::MessageEvent.new(payload)
      message.register_say_handler(method(:say))

      message_handlers.each do |handler|
        match = handler.match(payload.event)
        next unless match

        handler.run(self, message, match)
        break
      end
    end

    def say(message_event, params = {})
      client.chat_postMessage(
        {
          channel: message_event.raw_payload.event.channel,
          as_user: true
        }.merge(params)
      )
    end

    def on_event(payload)
      @logger.debug("event payload: #{payload}")

      event = Events::GeneralEvent.new(payload)

      event_handlers.each do |handler|
        next unless handler.match?(event)

        handler.run(self, event)
      end
    end
  end
end
