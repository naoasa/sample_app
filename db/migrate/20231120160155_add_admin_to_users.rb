class AddAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :admin, :boolean, default: false # デフォルトでは管理者にはなれないことを示す
  end
end
