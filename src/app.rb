require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'uri'
require 'json'

require "#{__dir__}/message_template.rb"

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

  type = params[:type]
  case type
  when 'text', nil
    data["messages"] = [
      create_msg_plaintext(params[:message])]
  when 'location'
    data["messages"] = [
      create_msg_confirmtmp(params[:title],
                            params[:address],
                            params[:lat],
                            params[:lon])]
  when 'confirm'
    data["message"] = [
      create_msg_confirmtmp(params[:alt_text],
                            params[:text],
                            params[:true_text],
                            params[:false_text])]
  else
    return JSON.dump({
      code: 400,
      message: "Type '#{type}' is undefined."
    })
  end

  # post
  res = send_post(url, data)

  # 結果をhashに格納
  json = {
    code: res.code,
    message: JSON.parse(res.body)["message"]
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
    case parsed["type"]
    when "message"
      if parsed["message"]["text"].strip == "id"
        url = "#{END_POINT}/reply"
  
        data = {}
        data["replyToken"] = parsed["replyToken"]
        data["messages"] = [create_plaintext(parsed["source"]["userId"])]
        res = send_post(url, data)
  
        # 結果をhashに格納
        json = {
          code: res.code,
          message: JSON.parse(res.body)["message"]
        }
        # hashをjson形式で出力
        JSON.dump(json)
      else
      end
    when "follow"
      # 友達追加
      # TODO: このアカウントの説明をしたい
    when "join"
      # グループ、トークルームに参加
    when "postback"
      # リッチテキストのボタン押下イベント等
    else
    end
  end
end
