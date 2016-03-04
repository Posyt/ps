# class ProductHuntScraper
#   include Sidekiq::Worker
#   include Sidetiq::Schedulable
#
#   sidekiq_options retry: false
#
#   recurrence { hourly.minute_of_hour(0, 30) }
#
#   def perform
#     urls = [
#       'https://www.producthunt.com/feed.atom'
#     ]
#     urls.each { |url| handle_url(url) }
#   end
#
#   def handle_url url
#     # xml = Faraday.get(url).body
#     # feed = Feedjira::Feed.parse xml
#     # feed.entries.each do |e|
#     #   title_attrs = e.title.split("&#8211;")
#     #
#     #   attrs = {}
#     #   attrs[:source] = "Hacker News"
#     #   attrs[:points] = title_attrs.shift().to_i
#     #   attrs[:title] = title_attrs.join("-").strip
#     #   attrs[:url] = e.links.first
#     #   attrs[:comments_url] = e.entry_id
#     #   attrs[:author] = e.author
#     #   attrs[:published_at] = DateTime.parse(e.published.to_s)
#     #   attrs[:comments] = e.content.scan(/">.{0,1}(\d+).{0,1}comments/).flatten.first.to_i
#     #   attrs[:normalized_popularity] = (attrs[:points] + attrs[:comments])/15 # assumes 1500 as soft maximum points + comments
#     #
#     #   Article.delay(queue: 'default', retry: false).create_or_update(attrs)
#     # end
#   end
# end
