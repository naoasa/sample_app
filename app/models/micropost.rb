class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable| # 画像ファイルとMicropostモデルを関連付ける
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) } # created_atの降順 => 最新の投稿順
  validates :user_id, presence: true # user_idが存在する
  validates :content, presence: true, length: { maximum: 140 } # contentは存在し、最大文字数は140
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message:   "should be less than 5MB" }
end
