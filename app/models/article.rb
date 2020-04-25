class Article < ApplicationRecord
  belongs_to :fiverr_order
  belongs_to :order_type
  belongs_to :writingstatus
  belongs_to :payment_status

  validates :due_date,:order_type_id, :presence => true
end
