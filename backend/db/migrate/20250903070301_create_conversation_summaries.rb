class CreateConversationSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_summaries do |t|
      t.references :chat_session, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :turn_count, null: false, default: 0
      t.timestamps
    end
  end
end
