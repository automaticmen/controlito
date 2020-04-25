class AddColumnCustomOfferToFiverrOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :custom_offer, :boolean
  end
end
