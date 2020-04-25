class FiverrOrder < ApplicationRecord
    belongs_to :order_type
    belongs_to :order_status
    belongs_to :server

    has_many :article , inverse_of: :fiverr_order
    accepts_nested_attributes_for :article , reject_if: lambda {|attributes| attributes['due_date'].blank?}

    validates :order_no,:username,:due_date,:order_type_id,:order_status_id, :presence => true
    validates :order_no, uniqueness:{:case_sesitive => false}
end
