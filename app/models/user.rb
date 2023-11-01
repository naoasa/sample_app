class User < ApplicationRecord
    attr_accessor :remember_token # 外部からremember_tokenにアクセスできるようにする
    before_save { email.downcase! } # save前に小文字に変換
    validates :name, presence: true, length: { maximum: 50 }
    # emailの正規表現を定義(大文字で始まるものは定数)
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                                      format: { with: VALID_EMAIL_REGEX },
                                      uniqueness: true
    has_secure_password # セキュアなパスワードを持つ
    validates :password, presence: true, length: { minimum: 8 }

    # 渡された文字列のハッシュ値を返す
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def self.new_token
        SecureRandom.urlsafe_base64
    end

    # 永続的セッションのためにユーザーをデータベースに記憶する(rememberメソッド)
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # 渡されたトークンがダイジェストと一致したらtrueを返す(authenticated?メソッド)
    def authenticated?(remember_token) # remember_tokenを受け取る
        return false if remember_digest.nil? # ダイジェストがnilならfalseを返す
        BCrypt::Password.new(remember_digest).is_password?(remember_token) # ここの(remember_token)は、メソッド内のローカル変数を参照している
    end

    # ユーザーのログイン情報を破棄する(forgetメソッド)
    def forget
        update_attribute(:remember_digest, nil) # 記憶ダイジェストをnilで更新
    end
end