class AddColumnComments < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :comments, :text
  end
end
