# coding: utf-8
require 'faraday'
require 'mechanize'

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require 'maiwork_config'

class Chat
  def initialize
    @conn = Faraday::Connection.new(url: 'https://api.chatwork.com') do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Response::Logger
      builder.use Faraday::Adapter::NetHttp
    end
  end

  def message=(text)
    @conn.post do |request|
      request.url "/v1/rooms/#{ROOM_ID}/messages"
      request.headers = {
        'X-ChatWorkToken' => CHATWORK_TOKEN
      }
      request.params[:body] = text
    end
  end
end

chat = Chat.new
chat.message = 'Ruby スクリプトからの api 投稿'
