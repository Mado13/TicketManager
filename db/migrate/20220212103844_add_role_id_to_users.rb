class AddRoleIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :role, null: true, foreign_key: true
  end
end
