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
def create_msg_plaintext(msg)
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
      to = params[:to].strip
    end
  end

  # post用のdataを作成
  data = {}
  data["to"] = to
  data["messages"] = [create_msg_plaintext(params[:message])]

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
  body = request.body.read
  if body == ''
    status 400
  else
    parsed = JSON.parse(body)["events"][0]
    # メッセージがidだった場合、メッセージ送信者のuser_idを返す
    if parsed["type"] == "message" && parsed["message"]["text"].strip == "id"
      url = "#{END_POINT}/reply"

      data = {}
      data["replyToken"] = parsed["replyToken"]
      data["messages"] = [create_plaintext(parsed["source"]["userId"])]
      res = send_post(url, data)

      # 結果をhashに格納
      json = {
        "code": res.code,
        "message": JSON.parse(res.body)["message"]
      }
      # hashをjson形式で出力
      JSON.dump(json)
    else
    end
  end
end
