class ProductHuntScraper
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false

  recurrence { hourly.minute_of_hour(0, 30) }

  def perform
    urls = [
      'https://www.producthunt.com/feed.atom'
    ]
    urls.each { |url| handle_url(url) }
  end

  def handle_url url
    xml = Faraday.get(url).body
    feed = Feedjira::Feed.parse xml
    feed.entries.each_with_index do |e, i|
      title_attrs = e.title.split("&#8211;")

      attrs = { sources: [{}] }
      attrs[:sources][0][:name] = "Product Hunt"
      attrs[:sources][0][:title] = e.title
      attrs[:sources][0][:categories] = e.categories
      attrs[:sources][0][:description] = e.content
      attrs[:url] = e.url
      attrs[:sources][0][:url] = e.content.scan(/"(.*)">Discussion/).flatten.first
      attrs[:sources][0][:author] = e.author
      attrs[:sources][0][:published_at] = DateTime.parse(e.published.to_s)
      # TODO: points, comments, normalized_popularity

      Article.delay_for((i*2).seconds, queue: 'default', retry: 2).create_or_update(attrs)
    end
  end
end
