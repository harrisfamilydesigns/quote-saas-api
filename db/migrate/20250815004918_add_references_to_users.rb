class AddReferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :contractor, null: false, foreign_key: true
    add_reference :users, :supplier, null: false, foreign_key: true
  end
end
