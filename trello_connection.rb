require 'trello'
#
class TrelloConnection
  def initialize
    Trello.configure do |config|
      config.consumer_key = ENV['TRELLO_CONSUMER_KEY']
      config.consumer_secret = ENV['TRELLO_CONSUMER_SECRET']
      config.oauth_token = ENV['TRELLO_OAUTH_TOKEN']
    end
    @lists = Trello::Board.find(ENV['TRELLO_BOARD']).lists
  end

  def help(user)
    content(user)
  end

  def reply(user, messages)
    id = id(messages[1])
    return not_understand(user, messages[1]) if id.nil?
    lists(id)
    return not_understand(user, messages[1]) if @lists.blank?
    return content(user, messages[1]) if messages[2].nil?
    id = id(messages[2])
    return not_understand(user, messages[2]) if id.nil?
    "<@#{user}>\r\n#{messages[2]}\r\n\r\n```#{desc(id)}```"
  end

  def content(user, name=nil)
    text = "<@#{user}>\r\n"
    text << 'お問い合わせ内容を選択して!!' + "\r\n\r\n"
    text << '```'
    @lists.each do |value|
      next if value.name =~ /^skip/
      text << value.name + "\r\n"
    end
    text << ' ``` '
    text << '下記のフォーマットでお問い合わせしてみてー' + "\r\n\r\n"
    text << '```'
    text << ENV['SLACK_BOT_NAME']
    text << " #{name}" if name.present?
    text << ' お問い合わせ内容'
    text << ' ```'
    text
  end

  def not_understand(user, message)
    Trello::Card.create(name: message, list_id: ENV['TRELLO_LIST_NOT_UNDERSTAND'])
    text = "<@#{user}>\r\n"
    text << '私には理解できませんので、管理者にお伝えしておきます。\r\n'
    text << '#adm-contactにお問い合わせしてください。'
    text
  end

  def id(name)
    @lists.each do |value|
      return value.id if name == value.name
    end
    nil
  end

  def lists(id)
    @lists = Trello::List.find(id).cards
  end

  def desc(id)
    Trello::Card.find(id).desc
  end
end
