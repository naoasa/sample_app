class AddActivationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, default: false # デフォルトではfalse(有効化されていない)にしておく
    add_column :users, :activated_at, :datetime
  end
end
