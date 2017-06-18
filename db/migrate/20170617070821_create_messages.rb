class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.integer :conversation_id
      t.text :content
      t.integer :sender_id
      t.boolean :is_read

      t.timestamps
    end
  end
end
