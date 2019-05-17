# プレーンテキストメッセージ作成
def create_msg_plaintext(msg)
  {
    type: 'text',
    text: msg
  }
end

# ロケーションメッセージ作成
def create_msg_location(title, address, lat, lon)
  {
    type: 'location',
    title: title,
    address: address,
    latitude: lat,
    longitude: lon,
  }
end

# 確認テンプレート作成
def create_msg_confirmtmp(alt_text, text, true_text, false_text)
  {
    type: 'template',
    altText: alt_text,
    template: {
        type: 'confirm',
        text: text,
        actions: [
            {
              type: 'message',
              label: 'True',
              text: true_text
            },
            {
              type: 'message',
              label: 'False',
              text: false_text
            }
        ]
    }
  }
end

