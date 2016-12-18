class ImgurScraper
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false

  recurrence { hourly.minute_of_hour(0, 30) }

  def perform
    url = "http://imgur.com/"
    mech = Mechanize.new
    front_page = mech.get(url)
    pages = []
    front_page.search(".post a")[0..29].each do |link|
      pages << mech.click(link) rescue nil
    end
    pages.compact!
    pages.each_with_index { |page, i| handle_page(page, i) }
  end

  def handle_page p, i
    attrs = { sources: [{}] }
    attrs[:source] = "Imgur"
    attrs[:title] = p.search(".post-title").text.strip rescue nil
    attrs[:url] = p.uri.to_s rescue return
    attrs[:author] = p.search(".post-account").text.strip rescue nil
    # attrs[:published_at] = DateTime.parse(e.published.to_s)
    attrs[:image_url] = p.search(".post-images img").first.attributes["src"].value rescue p.search(".post-images source").first.attributes["src"].value.gsub(".mp4", ".gif") rescue nil
    attrs[:summary] = p.search(".post-description").to_html rescue nil
    attrs[:description] = Article.html_to_s(p.search(".post-description").to_html) rescue nil
    # attrs[:categories] = e.categories

    Article.delay_for((i*2).seconds, queue: 'default', retry: 2).create_or_update(attrs)
  end
end
