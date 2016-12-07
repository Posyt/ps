# NOTE: this is just a stub to render in rails admin
# The real model is in the pm meteor service
class User
  include Mongoid::Document
  # include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic

  field :username, type: String
  field :createdAt, type: Date
  field :meta, type: Object
end
