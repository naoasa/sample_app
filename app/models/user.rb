class User < ApplicationRecord
    before_save { email.downcase! } # save前に小文字に変換
    validates :name, presence: true, length: { maximum: 50 }
    # emailの正規表現を定義(大文字で始まるものは定数)
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                                      format: { with: VALID_EMAIL_REGEX },
                                      uniqueness: true
    has_secure_password # セキュアなパスワードを持つ
    validates :password, presence: true, length: { minimum: 8 }
end
