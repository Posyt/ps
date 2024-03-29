class Article
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Attributes::Dynamic
  include SearchableArticle
  include GraphableArticle

  field :categories, type: Array, default: [] # e.g. tech, podcasts, books
  index  categories: 1
  field :url, type: String # e.g. the most direct link to the article, try to click through short/tracking links and scrape the original if possible
  index  url: 1
  field :title, type: String
  index  title: 1
  field :source, type: String # e.g. the original source of the article like New York Times or Medium
  index  source: 1
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

  # NOTE: these are modified by pm the node.js server, thus the camelCase
  field :numLikesReceived, type: Integer, default: 0
  index  numLikesReceived: 1
  field :numSkipsReceived, type: Integer, default: 0
  index  numSkipsReceived: 1
  field :numReports, type: Integer, default: 0
  index  numReports: 1
  field :numConversations, type: Integer, default: 0
  index  numConversations: 1

  # field :scrape_meta, type: Hash # information that might be used to recreate the scrape that got this data
  field :scrape_times, type: Array, default: []

  validates :url, presence: true, uniqueness: true
  validates :title, length: { maximum: 1000 }

  # NOTE: store references to the discovery sources here e.g. Hacker News and Product Hunt listings
  embeds_many :sources
  accepts_nested_attributes_for :sources

  before_save :scrape
  # TODO: index in elasticsearch on save

  def self.create_or_update attrs
    # Normalize the url for consistency
    attrs[:url] = Article.normalize_url(attrs[:url])
    # Wait a second so future scrapes don't get 503 errors
    sleep(rand(4..7))
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

  def self.parse_feed rss_url
    xml = Faraday.get(rss_url).body
    feed = Feedjira::Feed.parse xml
  end

  def self.html_to_s html_string
    Sanitize.clean(html_string).strip
  end

  def self.use_url? url
    blacklist = [
      'libsyn.com', # Product Hunt podcast url - it get's generated on every redirect with an expiration token, so it fails deduplication
    ]
    (url =~ /#{blacklist.join('|')}/i).nil?
  end

  def self.normalize_url url
    # Follow redirects to get actual url
    resolved_url = Article.resolve_redirects(url)
    url = resolved_url if Article.use_url?(resolved_url)
    # Normalize url by removing query and fragment
    uri = Addressable::URI.parse(url)
    params_to_remove = /rer|utm|emc|partner|gi|OP|app_id/
    uri.query_values = uri.query_values.delete_if { |k,v| params_to_remove === k.downcase } if uri.query_values
    result = uri.to_s
    result = result[0...-1] if result.last == "?"
    return result
  end

  def self.resolve_redirects(url)
    response = Article.fetch_response(url, method: :head)
    if response
        return response.to_hash[:url].to_s
    else
        return Faraday.get(url)["location"] rescue url
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

  def self.find_best_image image_urls
    biggest = 0
    best = nil
    image_urls.each do |url|
      size = FastImage.size(url)
      hypotenuse = Math.sqrt(size[0]**2 + size[1]**2)
      if hypotenuse > biggest
        best = url
        biggest = hypotenuse
      end
      return best if hypotenuse > 300 # Stop looking if image greater than 300 pixels diagonal
    end
    best
  end

  def merge_attrs attrs
    return false if self.url != attrs[:url] # can't merge attrs if top level url does not match
    # Whitelist setable attributes and overwrite them on the article
    setable_fields = [:source, :title, :description, :image_url, :published_at, :author, :summary, :points, :comments, :normalized_popularity]
    setable_attrs = attrs.slice(*setable_fields)
    self.attributes = setable_attrs
    # Limit string sizes
    self.title = self.title[0...1000] if self.title
    self.description = self.description[0...1000] if self.description
    self.summary = self.summary[0...2000] if self.summary
    # Merge categories
    self.categories = (self.categories || []) | attrs[:categories].map(&:downcase) if attrs.has_key?(:categories)
    # Merge sources
    if attrs.has_key?(:sources)
      setable_fields -= [:source]
      setable_fields += [:name, :url]
      attrs[:sources].each do |s|
        # Only persist sources with a name
        next unless s.has_key?(:name)
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
        # Append the scrape time
        source.scrape_times += [DateTime.now]
        # Update Timestamps - it's a nested doc so they don't auto update
        source.created_at = DateTime.now unless source.created_at
        source.updated_at = DateTime.now
      end
    end
    return true
  end

  def scrape
    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    page = agent.get(self.url)
    !self.title && self.title = page.title.strip rescue self.title
    !self.summary && self.summary = page.at("head meta[name='description']")["content"].strip rescue self.summary
    !self.description && self.description = Article.html_to_s(self.summary).gsub("  ", "") rescue self.description
    !self.author && self.author = page.at("head meta[name='author']")["content"].strip rescue self.author
    !self.categories && self.categories = self.categories | page.at("head meta[name='keywords']")["content"].split(",").map(&:strip).map(&:downcase) rescue self.categories
    !self.image_url && self.image_url = Article.find_best_image(page.images.map(&:to_s)) rescue self.image_url
    !self.source && self.source = URI.parse(self.url).host.downcase rescue self.source
    true
  end
end
