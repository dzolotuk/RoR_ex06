class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :session_id, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :orders, :session_id
  end
end
