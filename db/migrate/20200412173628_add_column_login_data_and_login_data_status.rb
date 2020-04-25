class AddColumnLoginDataAndLoginDataStatus < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :login_data, :boolean
    add_column :fiverr_orders , :login_data_status, :integer
  end
end
