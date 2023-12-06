class Micropost < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true # user_idが存在する
  validates :content, presence: true, length: { maximum: 140 } # contentは存在し、最大文字数は140
end
