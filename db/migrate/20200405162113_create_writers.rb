class CreateWriters < ActiveRecord::Migration[5.1]
  def change
    create_table :writers do |t|
      t.string :name
      t.string :comments
      t.string :work_details
      t.integer :priority

      t.timestamps
    end
  end
end
