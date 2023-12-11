# メインのサンプルユーザーを1人作成する
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar123",
             password_confirmation: "foobar123",
             admin:     true, # 管理者である
             activated: true, # 有効化済み
             activated_at: Time.zone.now) # 有効化タイムスタンプ

# 追加のユーザーをまとめて生成する
99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true, # 有効化済み
               activated_at: Time.zone.now) # 有効化タイムスタンプ
end

# ユーザーの一部を対象にマイクロポストを生成する
users = User.order(:created_at).take(6) # 最初の6人のユーザーを格納
50.times do
  content = Faker::Lorem.sentence(word_count: 5) # Faker gemを利用
  users.each { |user| user.microposts.create!(content: content) }
end