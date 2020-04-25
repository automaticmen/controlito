class CreateFiverrOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :fiverr_orders do |t|
      t.string :order_no
      t.string :username

      t.timestamps
    end
  end
end
