class AddServerReferenceToFiverrOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :fiverr_orders, :server, foreign_key: true
  end
end
