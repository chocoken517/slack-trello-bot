require 'dotenv'
Dotenv.load
require './trello_connection'
require './slack'

puts TrelloConnection.new
