class DribbbleScraper
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false

  recurrence { hourly.minute_of_hour(0, 30) }

  def perform
    urls = [
      'https://dribbble.com/shots/popular.rss',
      'https://dribbble.com/stories.rss'
    ]
    urls.each { |url| handle_url(url) }
  end

  def handle_url url
    feed = Article.parse_feed url
    feed.entries.each_with_index do |e, i|
      attrs = { sources: [{}] }
      attrs[:source] = "Dribbble"
      attrs[:title] = e.title
      attrs[:url] = e.url
      attrs[:author] = e.author
      attrs[:published_at] = DateTime.parse(e.published.to_s)
      attrs[:image_url] = e.summary.scan(/src="(.*)"/).flatten.first
      attrs[:summary] = e.summary
      attrs[:description] = Article.html_to_s(e.summary)
      attrs[:categories] = e.categories

      Article.delay_for((i*2).seconds, queue: 'default', retry: 2).create_or_update(attrs)
    end
  end
end
