class AddPasswordDigestToUsers < ActiveRecord::Migration[7.0]
  def change
    # add_columnメソッドでusersテーブルにpassword_digestカラムを追加する
    add_column :users, :password_digest, :string
  end
end
