require 'trello'
class TrelloConnection
  def initialize
    Trello.configure do |config|
      config.consumer_key = ENV['TRELLO_CONSUMER_KEY']
      config.consumer_secret = ENV['TRELLO_CONSUMER_SECRET']
      config.oauth_token = ENV['TRELLO_OAUTH_TOKEN']
    end
    @board = Trello::Board.find(ENV['TRELLO_BOARD'])
  end

  def help
    text = 'お問い合わせ内容を選択して\n\n'
    text << list_names
    text << '上記の中から選択して下記のお問い合わせ\n'
    text << ENV['SLACK_BOT_NAME'] + ' [お問い合わせ内容]'
    text
  end

  def list_names
    text = ''
    @board.lists.each do |value|
      next if value.name.match(/^skip/)
      text << value.name + '\n'
    end
    text
  end

  def list_id(name)
    @board.lists.each do |value|
      return value.id if name == value.name
    end
  end

  def lists(id)
    @list = Trello::List.find(id)
  end

  def card_names
    @list.cards.each do |value|
      text << value.name + '\n'
    end
  end

  def card_id(name)
    @list.cards.each do |value|
      return value.id if name == value.name
    end
  end

  def desc(id)
    Trello::Card.find(id).desc
  end
end
