class MediumScraper
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false

  recurrence { hourly.minute_of_hour(0, 30) }

  def perform
    url = "https://medium.com/"
    mech = Mechanize.new
    pages = []
    pages << mech.get(url)
    pages << mech.click(pages.first.link_with(text: "Editors’ picks")) rescue nil
    pages << mech.click(pages.first.link_with(text: "Top stories")) rescue nil
    pages << mech.click(pages.first.link_with(text: "Eye candy")) rescue nil
    pages.compact!
    pages.each { |page| handle_page(page) }
  end

  def handle_page page
    articles = page.search(".streamItem")
    articles.each_with_index do |a, i|
      attrs = { sources: [{}] }
      attrs[:source] = "Medium"
      attrs[:title] = a.at("h3").text.strip rescue next
      attrs[:url] = a.search(".layoutSingleColumn > a").first.attributes["href"].value.strip.split("?").first rescue a.search(".postArticle-content > a").first.attributes["href"].value.strip.split("?").first rescue nil
      attrs[:author] = a.search('.postMetaInline-authorLockup > a').first.text.strip rescue nil
      attrs[:published_at] = a.search('.js-postMetaInlineSupplemental time').first.attributes["datetime"].value.to_datetime rescue nil
      attrs[:image_url] = a.search(".section-inner img").first.attributes["src"].value rescue a.search(".postArticle-content img").first.attributes["src"].value rescue nil
      attrs[:summary] = a.search("p").to_html rescue a.search("h4").to_html rescue ""
      attrs[:description] = Article.html_to_s(a.search("p").to_html) rescue Article.html_to_s(a.search("h4").to_html) rescue ""
      Article.delay_for((i*2).seconds, queue: 'default', retry: 2).create_or_update(attrs)
    end
  end
end
