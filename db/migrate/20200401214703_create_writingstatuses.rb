class CreateWritingstatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :writingstatuses do |t|
      t.string :status

      t.timestamps
    end
  end
end
