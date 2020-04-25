class AddExtrasStatusReferenceToFiverrOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :fiverr_orders, :extras_status, foreign_key: true
  end
end
