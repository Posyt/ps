class Article
  # TODO: scrape the top level url on create
  # TODO: index in elasticsearch on save

  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic
  field :source, type: String # e.g. the original source of the article like New York Times or Medium
  index  source: 1
  field :url, type: String # e.g. the most direct link to the article, try to click through short/tracking links and scrape the original if possible
  index  url: 1
  field :title, type: String
  index  title: 1
  field :description, type: String
  index  description: 1
  field :image_url, type: String
  index  image_url: 1
  field :published_at, type: DateTime
  index  published_at: 1
  field :author, type: String
  index  author: 1
  field :summary, type: String
  index  summary: 1
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

  validates :url, presence: true, uniqueness: true
  validates :title, length: { maximum: 1000 }

  # NOTE: store references to the discovery sources here e.g. Hacker News and Product Hunt listings
  embeds_many :sources
  accepts_nested_attributes_for :sources

  def self.create_or_update attrs
    article = Article.find_by(url: attrs[:url]) rescue nil
    if article
      raise "Failed to merge Article attributes" unless article.merge_attrs(attrs)
      article.save!
    else
      article = Article.create!(attrs)
    end
    article.push(scrape_times: DateTime.now)
  end

  def merge_attrs attrs
    return false if self.url != attrs[:url] # can't merge attrs if top level url does not match
    # Whitelist setable attributes and overwrite them on the article
    setable_fields = [:source, :title, :description, :image_url, :published_at, :author, :summary, :points, :comments, :normalized_popularity]
    setable_attrs = attrs.slice(*setable_fields)
    self.attributes = setable_attrs
    # Merge categories
    self.categories = (self.categories || []) | attrs[:categories] if attrs.has_key?(:categories)
    # Merge sources
    if attrs.has_key?(:sources)
      setable_fields -= [:source]
      setable_fields += [:name, :url]
      attrs[:sources].each do |s|
        source = self.sources.find_by(name: s[:name]) rescue self.sources.new(name: s[:name])
        setable_attrs = s.slice(*setable_fields)
        source.attributes = setable_attrs
        source.categories = (source.categories || []) | s[:categories] if s.has_key?(:categories)
        # Set a temporary title and published_at if none exist
        self.title = s[:title] unless self.title
        self.published_at = s[:published_at] unless self.published_at
        # Append the scrape time
        source.scrape_times += [DateTime.now]
      end
    end
    return true
  end
end
