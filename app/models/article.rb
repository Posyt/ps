class Article
  include Mongoid::Document
  include Mongoid::Timestamps
  field :url, type: String # e.g. the article
  field :comments_url, type: String # e.g. the Hacker News page
  field :title, type: String
  field :description, type: String
  field :image_url, type: String
  field :published_at, type: DateTime
  field :source, type: String # e.g. Hacker News
  field :author, type: String
  field :summary, type: String
  field :points, type: Integer # e.g. number of upvotes
  field :comments, type: Integer # e.g. number of comments
  field :normalized_popularity, type: Integer # calculated by scraper, ideally between 0 - 100, based on upvotes, comments, etc.

  # field :scrape_meta, type: Hash # information that might be used to recreate the scrape that got this data
  field :scrape_times, type: Array

  index({ url: 1 }, { unique: true })
  index({ comments_url: 1 }, { unique: true, sparse: true })
  index({ title: 1 }, {})
  index({ description: 1 }, {})
  index({ image_url: 1 }, {})
  index({ published_at: 1 }, {})
  index({ source: 1 }, {})
  index({ author: 1 }, {})
  index({ summary: 1 }, {})
  index({ points: 1 }, {})
  index({ comments: 1 }, {})
  index({ normalized_popularity: 1 }, {})

  validates :url, presence: true, uniqueness: true
  validates :source, presence: true

  def self.create_or_update attributes
    article = Article.find_by(url: attributes.url)
    if article
      article.update_attributes!(attributes)
    else
      article = Article.create!(attributes)
    end
    article.push(scrape_times: DateTime.now)
  end
end
