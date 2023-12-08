class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) } # created_atの降順 => 最新の投稿順
  validates :user_id, presence: true # user_idが存在する
  validates :content, presence: true, length: { maximum: 140 } # contentは存在し、最大文字数は140
end
