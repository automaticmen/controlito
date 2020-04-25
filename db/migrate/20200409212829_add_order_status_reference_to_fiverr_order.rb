class AddOrderStatusReferenceToFiverrOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :fiverr_orders, :order_status, foreign_key: true
  end
end
