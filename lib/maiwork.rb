# coding: utf-8
require 'faraday'
require 'mechanize'

class Chat
  ROOM_ID = 'room_id' # room id
  CHATWORK_TOKEN = 'apitoken' # api token

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

agent = Mechanize.new
agent.user_agent_alias = 'Mac Firefox'
page = agent.get('https://accounts.google.com/')
sso_page = page.form_with(id: 'gaia_loginform') do |form|
  form.Email = 'emailaddress' # email address
end.submit
acs_page = sso_page.form_with(name: 'flogin') do |form|
  form.uid = 'userid' # user id
  form.password = 'password' # pass word
end.submit
redirect_page = acs_page.form_with(name: 'acsForm') do |form|
end.submit
redirect_page.link_with(text: 'Continue').click
gmail_page = agent.get('https://mail.google.com/mail/u/0/?shva=1#inbox')
gmail_page.body.each_line do |line|
  case line.force_encoding('utf-8')
  when /(\[Bigman\(production\)\]\[ERROR\] .+?)\\.+?(\d+年\d+月\d+日 \d+:\d+)/
    chat.message = "#{$1} #{$2}"
  end
end
