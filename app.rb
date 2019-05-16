require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'uri'
require 'json'

END_POINT = "https://api.line.me/v2/bot/message"

# post送信
def send_post(url, data)
  uri = URI.parse(url)
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{ENV['ACCESS_TOKEN']}"
  # request.set_form_data(data)
  request.body = JSON.dump(data)
  req_options = {use_ssl: uri.scheme == "https"}
  return Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
end

# プレーンテキストメッセージ作成
def create_plaintext(msg)
  {
    type: 'text',
    text: msg
  }
end

get '/push' do
  # toパラメータの中身に合わせてurl,toを変更
  url = "#{END_POINT}/broadcast"
  to = ENV['CHANNEL_ID']
  if params[:to]
    if params[:to].split(",").size > 1
      url = "#{END_POINT}/multicast"
      to = params[:to].split(",")
    else
      url = "#{END_POINT}/push"
      to = params[:to].split
    end
  end

  # post用のdataを作成
  data = {}
  data["to"] = to
  data["messages"] = [create_plaintext(params[:message])]

  # post
  res = send_post(url, data)

  # 結果をhashに格納
  json = {
    "code": res.code,
    "message": JSON.parse(res.body)["message"]
  }
  # hashをjson形式で出力
  JSON.dump(json)
end

post '/webhook' do
  puts params["replyToken"] # token
  puts params["type"] # message
  puts params["source"]["type"] # user
  puts params["source"]["userId"] # userid
  puts params["message"]["id"] # id
  puts params["message"]["type"] # text
  puts params["message"]["text"] # message
  if params["type"] == "message" && params["message"]["text"].strip == "id"
    url = "#{END_POINT}/reply"
    data = {}
    data["replyToken"] = params["replyToken"]
    data["messages"] = [create_plaintext(params["source"]["userId"])]
    res = send_post(url, data)

    # 結果をhashに格納
    json = {
      "code": res.code,
      "message": JSON.parse(res.body)["message"]
    }
    # hashをjson形式で出力
    JSON.dump(json)
  end
  # params["replyToken"] # token
  # params["type"] # message
  # params["source"]["type"] # user
  # params["source"]["userId"] # userid
  # params["message"]["id"] # id
  # params["message"]["type"] # text
  # params["message"]["text"] # message
end
