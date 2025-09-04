class AddIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :messages, [ :chat_session_id, :created_at ]
    add_index :conversation_summaries, [ :chat_session_id, :created_at ]
    add_index :chat_sessions, [ :user_id, :updated_at ]
  end
end
