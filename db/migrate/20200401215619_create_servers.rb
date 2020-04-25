class CreateServers < ActiveRecord::Migration[5.1]
  def change
    create_table :servers do |t|
      t.string :name
      t.string :status
      t.string :comments
      t.string :last_reset
      t.string :problems
      t.string :notes

      t.timestamps
    end
  end
end
