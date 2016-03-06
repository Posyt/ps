class Source
  # TODO: scrape the top level url on create
  # TODO: index in elasticsearch on save

  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String # e.g. Hacker News or Product Hunt or Reddit etc...
  index  name: 1
  field :url, type: String # e.g. the link to the Hacker News page
  index  url: 1
  field :title, type: String
  index  title: 1
  field :description, type: String
  # index  description: 1
  field :image_url, type: String
  index  image_url: 1
  field :published_at, type: DateTime
  index  published_at: 1
  field :author, type: String
  index  author: 1
  field :summary, type: String
  # index  summary: 1 # NOTE: this sometimes contains html, so don't index it
  field :points, type: Integer # e.g. number of upvotes
  index  points: 1
  field :comments, type: Integer # e.g. number of comments
  index  comments: 1
  field :normalized_popularity, type: Integer # calculated by scraper, ideally between 0 - 100, based on upvotes, comments, etc.
  index  normalized_popularity: 1
  field :categories, type: Array, default: [] # e.g. tech, podcasts, books
  index  categories: 1

  # field :scrape_meta, type: Hash # information that might be used to recreate the scrape that got this data
  field :scrape_times, type: Array, default: []

  # validates :name, presence: true
  # validates :url, presence: true, uniqueness: true
  # validates :title, length: { maximum: 1000 }

  embedded_in :article
end
