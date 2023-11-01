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
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # 永続的セッションのためにユーザーをデータベースに記憶する
    def remember # rememberメソッドを定義
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end
end