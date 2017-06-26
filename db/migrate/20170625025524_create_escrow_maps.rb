class CreateEscrowMaps < ActiveRecord::Migration[5.1]
  def change
    create_table :escrow_maps do |t|
      t.integer :officer_id, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
