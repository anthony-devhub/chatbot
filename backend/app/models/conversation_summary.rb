class ConversationSummary < ApplicationRecord
  belongs_to :chat_session

  validates :content, presence: true
  validates :turn_count, numericality: { greater_than: 0 }
end
