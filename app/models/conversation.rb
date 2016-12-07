# NOTE: this is just a stub to render in rails admin
# The real model is in the pm meteor service
class Conversation
  include Mongoid::Document
  # include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic

  field :numMessages, type: String
  field :participantIds, type: Array
  field :lastMessage, type: Object
  field :likes, type: Array
  field :participants, type: Array
  field :createdAt, type: Date
end
