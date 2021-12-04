# frozen_string_literal: true

require 'sardonyx_ring'

class ExampleBot < SardonyxRing::App
  def greeting
    rand < 0.5 ? 'Hello,' : 'Fooo!'
  end

  def lottery_result
    rand < 0.5 ? 'GOOD!' : 'BAD!'
  end

  message 'Hello' do |message|
    message.say(text: "#{greeting} <@#{message.user}>!")
  end

  message 'modal' do |message|
    message.say(
      text: 'please click button!',
      blocks: [
        {
          type: 'actions',
          elements: [
            {
              type: 'button',
              action_id: 'click_open_button',
              text: {
                type: 'plain_text',
                text: 'Open Modal'
              },
              value: 'OpenModal'
            },
            {
              type: 'button',
              action_id: 'click_close_button',
              text: {
                type: 'plain_text',
                text: 'Close'
              },
              value: 'Close'
            }
          ]
        }
      ]
    )
  end

  action 'click_open_button' do |event|
    client.views_open(
      trigger_id: event.raw_payload.trigger_id,
      view: {
        type: 'modal',
        callback_id: 'modal',
        title: {
          type: 'plain_text',
          text: 'Sample Modal'
        },
        submit: {
          type: 'plain_text',
          text: 'Submit'
        },
        blocks: [
          {
            type: 'input',
            block_id: 'title_section',
            label: {
              type: 'plain_text',
              text: 'title'
            },
            element: {
              type: 'plain_text_input',
              action_id: 'title_value',
              placeholder: {
                type: 'plain_text',
                text: 'Enter article title'
              }
            }
          },
          {
            type: 'input',
            block_id: 'body_section',
            label: {
              type: 'plain_text',
              text: 'body'
            },
            element: {
              type: 'plain_text_input',
              action_id: 'body_value',
              multiline: true,
              placeholder: {
                type: 'plain_text',
                text: 'Enter article body'
              }
            }
          }
        ]
      }
    )
  end

  view 'modal' do |event|
    client.chat_postMessage(
      channel: event.raw_payload.user.id,
      text: 'You posted',
      attachments: [
        {
          title: event.state.values.title_section.title_value.value,
          text: event.state.values.body_section.body_value.value
        }
      ]
    )
  end

  action 'click_close_button' do |event|
    client.chat_update(
      channel: event.raw_payload.channel.id,
      ts: event.raw_payload.message.ts,
      blocks: [],
      attachments: [
        {
          text: 'This button is closed'
        }
      ]
    )
  end

  message(/\A(\d+)\z/) do |message, match|
    message.say(text: (match[1].to_i * 2).to_s)
  end

  message(/.+/) do |message|
    message.say(
      text: "This is <@#{message.user}>'s message!",
      attachments: [
        {
          fallback: message.text,
          text: message.text
        }
      ]
    )
  end

  event 'reaction_added' do |event|
    client.chat_postMessage(
      text: "reaction :#{event.reaction}: added by <@#{event.user}> !",
      channel: event.item.channel
    )
  end

  every '* * * * *' do
    channel = ENV['CRON_CHANNEL_ID']
    return unless channel

    client.chat_postMessage(
      text: "current time is #{Time.now}",
      channel: channel
    )
  end
end

ExampleBot.new(
  app_token: ENV['SLACK_APP_TOKEN'],
  bot_token: ENV['SLACK_BOT_TOKEN'],
  logger: Logger.new($stdout, level: :debug)
).socket_start!
