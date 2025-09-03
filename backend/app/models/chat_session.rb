class ChatSession < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy
  has_many :conversation_summaries, dependent: :destroy

  validates :user_id, presence: true
end
