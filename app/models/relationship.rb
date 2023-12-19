class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true # follower_idを存在させる
  validates :followed_id, presence: true # followed_idを存在させる
end
