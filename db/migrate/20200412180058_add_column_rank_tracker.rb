class AddColumnRankTracker < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :rank_tracker, :boolean
  end
end
