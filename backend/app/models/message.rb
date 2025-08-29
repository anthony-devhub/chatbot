class Message < ApplicationRecord
  belongs_to :chat_session

  enum :role, [ :user, :assistant ]

  validates :chat_session_id, :role, :content, presence: true
end
