class HackerNewsScraper
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false

  recurrence { hourly.minute_of_hour(0, 30) }

  def perform
    urls = [
      'http://hnapp.com/rss?q=score%3E10',
      'http://hnapp.com/rss?q=score%3E10&page=2',
      'http://hnapp.com/rss?q=score%3E10&page=3'
    ]
    urls.each { |url| handle_url(url) }
  end

  def handle_url url
    feed = Article.parse_feed url
    feed.entries.each_with_index do |e, i|
      title_attrs = e.title.split("&#8211;")

      attrs = { sources: [{}] }
      attrs[:sources][0][:name] = "Hacker News"
      attrs[:sources][0][:points] = title_attrs.shift().to_i
      attrs[:sources][0][:title] = title_attrs.join("-").strip
      attrs[:url] = e.links.first
      attrs[:sources][0][:url] = e.entry_id
      attrs[:sources][0][:author] = e.author
      attrs[:sources][0][:published_at] = DateTime.parse(e.published.to_s)
      attrs[:sources][0][:comments] = e.content.scan(/">.{0,1}(\d+).{0,1}comments/).flatten.first.to_i
      attrs[:sources][0][:normalized_popularity] = (attrs[:sources][0][:points] + attrs[:sources][0][:comments])/15 # assumes 1500 as soft maximum points + comments

      Article.delay_for((i*2).seconds, queue: 'default', retry: 2).create_or_update(attrs)
    end
  end
end
