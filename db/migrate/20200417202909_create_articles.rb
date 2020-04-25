class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.references :fiverr_order, foreign_key: true
      t.datetime :due_date
      t.references :order_type, foreign_key: true
      t.references :writers, foreign_key: true
      t.decimal :price
      t.references :writingstatus, foreign_key: true
      t.text :comments
      t.string :url
      t.string :key_word
      t.string :writing_code
      t.integer :article_amount
      t.integer :word_count
      t.references :payment_status, foreign_key: true
      t.datetime :payment_date
      t.string :payment_details

      t.timestamps
    end
  end
end
