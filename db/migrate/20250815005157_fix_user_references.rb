class FixUserReferences < ActiveRecord::Migration[8.0]
  def change
    # Remove null constraint from foreign keys since a user can be associated with either a contractor or a supplier, not both
    change_column_null :users, :contractor_id, true
    change_column_null :users, :supplier_id, true
  end
end
