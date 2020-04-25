class AddColumnSeoAuditAndSeoAuditStatus < ActiveRecord::Migration[5.1]
  def change
    add_column :fiverr_orders , :site_audit, :boolean
    add_column :fiverr_orders , :site_audit_status, :integer
  end
end
