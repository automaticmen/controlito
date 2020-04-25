class AddColumnStartDate < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :start_date, :datetime
  end
end
