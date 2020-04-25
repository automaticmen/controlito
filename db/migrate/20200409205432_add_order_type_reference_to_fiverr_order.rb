class AddOrderTypeReferenceToFiverrOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :fiverr_orders, :order_type, foreign_key: true
  end
end
