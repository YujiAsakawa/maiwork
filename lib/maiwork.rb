# coding: utf-8
require 'faraday'
require 'mechanize'
require 'json'

$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
require 'maiwork_config'

class Chat
  def initialize
    @conn = Faraday::Connection.new(url: 'https://api.chatwork.com') do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Response::Logger
      builder.use Faraday::Adapter::NetHttp
    end
    result = @conn.get do |request|
      request.url '/v1/me'
      request.headers = {
        'X-ChatWorkToken' => CHATWORK_TOKEN
      }
    end
    me = JSON.parse result.body
    @account_id = me['account_id']
    @room_id = me['room_id']
  end

  def message=(text)
    @conn.post do |request|
      request.url "/v1/rooms/#{@room_id}/messages"
      request.headers = {
        'X-ChatWorkToken' => CHATWORK_TOKEN
      }
      request.params[:body] = text
    end
  end

  def task=(text)
    @conn.post do |request|
      request.url "/v1/rooms/#{@room_id}/tasks"
      request.headers = {
        'X-ChatWorkToken' => CHATWORK_TOKEN
      }
      request.params[:body] = text
      request.params[:to_ids] = @account_id
    end
  end
end

chat = Chat.new
chat.message = 'api でメッセージ追加'
chat.task = 'api でタスク追加'
