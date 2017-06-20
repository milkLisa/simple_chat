class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.integer :conversation_id, null: false
      t.text :content, null: false
      t.integer :sender_id, null: false
      t.boolean :is_read, null: false, default: false

      t.timestamps null: false
    end
  end
end
