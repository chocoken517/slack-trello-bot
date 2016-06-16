require 'dotenv'
Dotenv.load
require 'slack-ruby-client'
require './trello_connection'

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
  next unless data.text.start_with?(ENV['SLACK_BOT_NAME'], "<@#{ENV['SLACK_BOT_NAME']}>")
  messages = data.text.split(' ')
  logger.info data.text
  client.typing channel: data.channel

  trello = TrelloConnection.new
  if %w(help h 助けて 助けろ た).include?(messages[1])
    client.message channel: data.channel, text: trello.help(data.user)
  else
    client.message channel: data.channel, text: trello.reply(data.user, messages)
  end
end

client.start_async

loop do
  Thread.pass
end
