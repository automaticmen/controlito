class AddColumnTrafficAndTrafficStatus < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :traffic, :boolean
    add_column :fiverr_orders , :site_traffic_status, :integer
  end
end
