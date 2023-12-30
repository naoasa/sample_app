class User < ApplicationRecord
    has_many :microposts, dependent: :destroy # マイクロポストを複数所有する, ユーザーとともに削除される
    has_many :active_relationships,  class_name:  "Relationship",
                                     foreign_key: "follower_id",
                                     dependent:   :destroy
    has_many :passive_relationships, class_name:  "Relationship",
                                     foreign_key: "followed_id",
                                     dependent:   :destroy
    has_many :following, through: :active_relationships,  source: :followed # following配列のソースはfollowed_idのコレクションであると明示
    has_many :followers, through: :passive_relationships, source: :follower # followers配列のソースはfollower
    attr_accessor :remember_token, :activation_token, :reset_token # 外部からアクセスできるようにする
    before_save   :downcase_email # ユーザー保存前にメソッド実行
    before_create :create_activation_digest # ユーザー作成前にメソッド実行
    validates :name, presence: true, length: { maximum: 50 }
    # emailの正規表現を定義(大文字で始まるものは定数)
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                                      format: { with: VALID_EMAIL_REGEX },
                                      uniqueness: true
    has_secure_password # セキュアなパスワードを持つ
    validates :password, presence: true, length: { minimum: 8 }, allow_nil: true

    class << self
        # 渡された文字列のハッシュ値を返す
        def digest(string)
            cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                          BCrypt::Engine.cost
            BCrypt::Password.create(string, cost: cost)
        end

        # ランダムなトークンを返す
        def new_token
            SecureRandom.urlsafe_base64
        end
    end

    # 永続的セッションのためにユーザーをデータベースに記憶する
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
        remember_digest
    end

    # セッションハイジャック防止のためにセッショントークンを返す
    # この記憶ダイジェストを再利用しているのは単に利便性のため
    def session_token
        remember_digest || remember
    end

    # 渡されたトークンがダイジェストと一致したらtrueを返す
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # ユーザーのログイン情報を破棄する(forgetメソッド)
    def forget
        update_attribute(:remember_digest, nil)
    end

    # アカウントを有効にする(= 有効化属性を更新する)
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    # 有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token # Userモデルでnew_tokenメソッドにより生成したトークンをreset_tokenに代入
        # update_attribute(:reset_digest,  User.digest(reset_token)) # 先ほど生成したトークンをもとにダイジェストを作成し、reset_digest属性を更新
        # update_attribute(:reset_sent_at, Time.zone.now) # 現在時刻で、reset_sent_at属性を更新
        # 上の2行を下記にリファクタリング
        update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    # パスワード再設定用のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # パスワード再設定の期限が切れている場合はtrueを返す(過ぎてるならtrue)
    def password_reset_expired?
        reset_sent_at < 2.hours.ago # パスワード再設定メールの送信時刻が現在時刻より2時間以上の場合
    end

    # ユーザーのステータスフィードを返す
    def feed
        following_ids = "SELECT followed_id FROM relationships
                         WHERE  follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids})
                         OR user_id = :user_id", user_id: id)
    end

    # ユーザーをフォローする
    def follow(other_user)
        following << other_user unless self == other_user # ユーザー自身がother_userでない限りは、following配列にother_userを追加する
    end

    # ユーザーをフォロー解除する
    def unfollow(other_user)
        following.delete(other_user) # 配列からother_userを削除
    end

    # 現在のユーザーが他のユーザーをフォローしていればtrueを返す
    def following?(other_user)
        following.include?(other_user) # following配列にother_userが含まれるか判定
    end

    private # 見せる必要はないメソッド置き場

        # メールアドレスをすべて小文字にする
        def downcase_email
            # self.email = email.downcaseを下記コードに改良
            email.downcase!
        end

        # 有効化トークンとダイジェストを作成, 代入する
        def create_activation_digest
            self.activation_token  = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end