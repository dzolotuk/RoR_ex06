class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      # The product can be deleted later: the order keeps its name and its price.
      t.references :product, foreign_key: { on_delete: :nullify }
      t.string :name, null: false
      t.decimal :unit_price, precision: 8, scale: 2, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
