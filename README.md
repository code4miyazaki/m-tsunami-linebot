# m-tsunami-linebot
ライン通知するためのWeb APIです。  
最終的にPOSTのみにする予定です。  

## heroku deploy
```sh
git push heroku master
```

## heroku 環境変数設定
Line Messaging APIの各設定値を指定してください。
```sh
heroku config:set CHANNEL_ID="<channel_id>"
heroku config:set CHANNEL_SECRET="<channel_secret>"
heroku config:set ACCESS_TOKEN="<access_token>"
```

## debug
```sh
# 環境変数設定
export CHANNEL_ID=<channel_id>
export CHANNEL_SECRET=<channel_secret>
export ACCESS_TOKEN=<access_token>

bundle install
ruby app.rb
```

## Usage
- 全ユーザーにpush通知  
    push通知したいメッセージをmessageで指定してください。
    ```
    http://localhost:4567/push?message=<message>
    ```

- 特定のユーザーにpush通知  
    toにユーザーIDを指定してください。
    ```
    http://localhost:4567/push?message=<message>&to=<user_id>
    ```

- 複数ユーザーにpush通知  
    toにコンマ区切りでユーザーIDを指定してください。
    ```
    http://localhost:4567/push?message=<message>?to=<user1_id>,<user2_id>
    ```


## Lineアカウント
![qr_code](assets/qr.png)
