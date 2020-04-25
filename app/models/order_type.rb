class OrderType < ApplicationRecord
    has_many :fiverr_order
    has_many :article
end
