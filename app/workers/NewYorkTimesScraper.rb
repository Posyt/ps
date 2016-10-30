class NewYorkTimesScraper
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false

  recurrence { hourly.minute_of_hour(0, 30) }

  def perform
    urls = [
      'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'
    ]
    urls.each { |url| handle_url(url) }
  end

  def handle_url url
    feed = Article.parse_feed url
    feed.entries.each_with_index do |e, i|
      attrs = { sources: [{}] }
      attrs[:source] = "New York Times"
      attrs[:title] = e.title
      attrs[:url] = e.url
      attrs[:author] = e.author
      attrs[:published_at] = DateTime.parse(e.published.to_s)
      # attrs[:image_url] = e.summary.scan(/src="(.*)"/).flatten.first # NOTE: just scrape the page, the image in this summary does not want to be scraped
      attrs[:summary] = e.summary
      attrs[:description] = Article.html_to_s(e.summary)

      # Exclude the crossword
      next if attrs[:title] =~ /crossword/i

      Article.delay_for((i*2).seconds, queue: 'default', retry: 2).create_or_update(attrs)
    end
  end
end
