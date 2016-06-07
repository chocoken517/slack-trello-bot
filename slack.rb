require 'dotenv'
Dotenv.load
require './trello_connection'
require 'slack-ruby-client'

fail 'Missing ENV[SLACK_API_TOKENS]!' unless ENV.key?('SLACK_API_TOKENS')

$stdout.sync = true
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

ENV['SLACK_API_TOKENS'].split.each do |token|
  logger.info "Starting #{token[0..12]} ..."

  client = Slack::RealTime::Client.new(token: token)

  client.on :hello do
    logger.info "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  end

  client.on :message do |data|
    logger.info data

    client.typing channel: data.channel

    case data.text
    when ENV['TRELLO_BOARD'] + ' hi' then
      client.message channel: data.channel, text: "Hi <@#{data.user}>!"
    when /^#{ENV['TRELLO_BOARD']}/ then
      client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
    end
  end

  client.start_async
end

loop do
  Thread.pass
end
