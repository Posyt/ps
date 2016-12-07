# NOTE: this is just a stub to render in rails admin
# The real model is in the pm meteor service
class Feeling
  include Mongoid::Document
  # include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic

  field :state, type: String
  field :content, type: String
  field :meta, type: Object
  field :ownerId, type: String
  field :createdAt, type: Date
end
