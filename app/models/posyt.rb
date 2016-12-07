# NOTE: this is just a stub to render in rails admin
# The real model is in the pm meteor service
class Posyt
  include Mongoid::Document
  # include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic

  field :content, type: String
  field :createdAt, type: Date
  field :numLikesReceived, type: Integer
  field :numSkipsReceived, type: Integer
  field :numReports, type: Integer
end
