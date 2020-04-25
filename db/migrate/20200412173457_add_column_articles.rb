class AddColumnArticles < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :articles, :boolean
  end
end
