require 'dotenv'
Dotenv.load
require './trello_connection'
require 'slack-ruby-client'

fail 'Missing ENV[SLACK_API_TOKEN]!' unless ENV.key?('SLACK_API_TOKEN')

$stdout.sync = true
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

logger.info 'Starting ...'

client = Slack::RealTime::Client.new(token: ENV['SLACK_API_TOKEN'])

client.on :hello do
  logger.info "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  logger.info data

  client.typing channel: data.channel

  case data.text
  when ENV['SLACK_BOT_NAME'] + ' hi' then
    client.message channel: data.channel, text: "Hi <@#{data.user}>!"
  when /^#{ENV['SLACK_BOT_NAME']}/ then
    client.message channel: data.channel, text: "Sorry <@#{data.user}>, what?"
  end
end

client.start_async

loop do
  Thread.pass
end
