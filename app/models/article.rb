class Article
  # TODO: scrape the top level url on create
  # TODO: index in elasticsearch on save

  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic
  field :categories, type: Array, default: [] # e.g. tech, podcasts, books
  index  categories: 1
  field :url, type: String # e.g. the most direct link to the article, try to click through short/tracking links and scrape the original if possible
  index  url: 1
  field :title, type: String
  index  title: 1
  field :source, type: String # e.g. the original source of the article like New York Times or Medium
  index  source: 1
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

  # field :scrape_meta, type: Hash # information that might be used to recreate the scrape that got this data
  field :scrape_times, type: Array, default: []

  validates :url, presence: true, uniqueness: true
  validates :title, length: { maximum: 1000 }

  # NOTE: store references to the discovery sources here e.g. Hacker News and Product Hunt listings
  embeds_many :sources
  accepts_nested_attributes_for :sources

  def self.create_or_update attrs
    # Normalize the url for consistency
    attrs[:url] = Article.normalize_url(attrs[:url])
    # Try to find a matching article
    article = Article.find_by(url: attrs[:url]) rescue nil
    # Update or create
    if article
      raise "Failed to merge Article attributes" unless article.merge_attrs(attrs)
      article.save!
    else
      article = Article.create!(attrs)
    end
    # Append scrape time
    article.push(scrape_times: DateTime.now)
  end

  def self.normalize_url url
    # Follow redirects to get actual url
    url = Article.resolve_redirects(url)
    # Normalize url by removing query and fragment
    parsed = URI::parse(url)
    parsed.fragment = parsed.query = nil
    return parsed.to_s
  end

  def self.resolve_redirects(url)
    response = Article.fetch_response(url, method: :head)
    if response
        return response.to_hash[:url].to_s
    else
        return nil
    end
  end

  def self.fetch_response(url, method: :get)
    conn = Faraday.new do |b|
      b.use FaradayMiddleware::FollowRedirects;
      b.adapter :net_http
    end
    return conn.send method, url
    rescue Faraday::Error, Faraday::Error::ConnectionFailed => e
    return nil
  end

  def merge_attrs attrs
    return false if self.url != attrs[:url] # can't merge attrs if top level url does not match
    # Whitelist setable attributes and overwrite them on the article
    setable_fields = [:source, :title, :description, :image_url, :published_at, :author, :summary, :points, :comments, :normalized_popularity]
    setable_attrs = attrs.slice(*setable_fields)
    self.attributes = setable_attrs
    # Merge categories
    self.categories = (self.categories || []) | attrs[:categories].map(&:downcase) if attrs.has_key?(:categories)
    # Merge sources
    if attrs.has_key?(:sources)
      setable_fields -= [:source]
      setable_fields += [:name, :url]
      attrs[:sources].each do |s|
        # Normalize the url
        s[:url] = Article.normalize_url(s[:url]) if s.has_key?(:url)
        # Find the source by name or create a new one
        source = self.sources.find_by(name: s[:name]) rescue self.sources.new(name: s[:name])
        # Set the setable attributes
        setable_attrs = s.slice(*setable_fields)
        source.attributes = setable_attrs
        # Merge categories
        source.categories = (source.categories || []) | s[:categories].map(&:downcase) if s.has_key?(:categories)
        self.categories = (self.categories || []) | s[:categories].map(&:downcase) if s.has_key?(:categories)
        # Set a temporary title and published_at on the parent Article if none exist
        self.title = s[:title] unless self.title
        self.published_at = s[:published_at] unless self.published_at
        # Append the scrape time
        source.scrape_times += [DateTime.now]
      end
    end
    return true
  end
end
