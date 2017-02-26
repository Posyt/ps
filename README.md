# Posyt Scraper

The Posyt news scraper


## Development

Start the posyt-meteor `pm` server.
MongoDB and Elasticsearch both run in the `pm` server, not here.

Start the server
```
./s
```

In a separate rails console (Only run this on initial configuration to create the index)
```
rake db:mongoid:create_indexes
Article.__elasticsearch__.create_index! force: true
```

### Re-map & Re-index

```
Article.__elasticsearch__.create_index! force: true
Article.all.each { |a| Indexer.perform_async('index', a.class.to_s, a._id.to_s) }
```


## Deployment

Just push to master and Heroku will take it from there

If you update a mongo index run:

```
heroku run rake db:mongoid:create_indexes
```

## TODO

http://ctrlq.org/rss/
https://www.rsssearchhub.com/

- [ ] fix duplicates like
http://www.crainsnewyork.com/article/20161030/REAL_ESTATE/161029841/12-firms-envision-ways-for-new-york-to-absorb-9-million-residents?CSAuthResp=1%3A273626979939598%3A220276%3A3%3A24%3Aapproved%3A535AD9EC5DBCED42128CEA53C4BACF0F
&
http://www.crainsnewyork.com/article/20161030/REAL_ESTATE/161029841/12-firms-envision-ways-for-new-york-to-absorb-9-million-residents?CSAuthResp=1%3A173626977631562%3A220276%3A3%3A24%3Aapproved%3AC16CF8A0FDB83C15CB9680D7F95A2DE0

- [ ] fix imgur - nothing is getting scraped - the rss url is not updating
- [ ] fix product hunt - not scraping much

- [x] Dribble
- [x] Hacker News
- [x] Imgur
- [x] New York Times
- [x] Product Hunt
- [x] The Verge
- [x] Medium
- [ ] Vice - https://www.vice.com/en_us/rss
- [ ] Vice - Creators Project - http://thecreatorsproject.vice.com/rss
- [ ] Vice - Motherboard - http://motherboard.vice.com/rss?trk_source=motherboard
- [ ] Kotaku
- [ ] Washington Post
- [ ] Wallstreet Journal
- [ ] Nautilus
- [ ] Business Insider
- [ ] Bloomberg
- [ ] 500px
- [ ] Instagram
- [ ] Deep Dot Web
- [ ] HBR
- [ ] Reuters
- [ ] Wiki News - https://en.wikinews.org/wiki/Main_Page
- [ ] Alternet - http://www.alternet.org/
- [ ] AP
- [ ] Independent - http://www.independent.co.uk/us
- [ ] The Intercept (Glenn Greenwald's site) - https://theintercept.com/
- [ ] The Onion
- [ ] RT - https://www.rt.com
- [ ] Sputnik - https://sputniknews.com/
- [ ] Aeon.co
- [ ] The New Yorker
- [ ] xkcd
- [ ] Ai Topics - http://aitopics.org/news
- [ ] Science Daily - https://www.sciencedaily.com/newsfeeds.htm
- [ ] MIT News = http://news.mit.edu/
- [ ] Academia.edu
- [ ] Designer News
- [ ] Techtronium - http://techtronium.com/
- [ ] arXiv
- [ ] NASA - PubSpace https://www.ncbi.nlm.nih.gov/pmc/funder/nasa/
- [ ] TODO: scrape book recommendations, ideally freely available books
- [ ] Upworthy
- [ ] TODO: find scientific journals with good free access papers
- [ ] First Round Review
- [ ] Science Mag
- [ ] Science Daily
- [ ] The Atlantic
- [ ] PewResearchCenter
- [ ] Gallup
- [ ] The Next Web
- [ ] Polygon
- [ ] Github Trending
- [ ] Wired
- [ ] Fast Company
- [ ] Politico Magazine
- [ ] Buzzfeed
- [ ] Reddit
- [ ] Trend Hunter
- [ ] The Economist
- [ ] Behance
- [ ] SoundCloud
- [ ] YouTube
- [ ] Twitch
- [ ] HypeMachine
- [ ] Niice.co
- [ ] Rational Wiki - http://rationalwiki.org/
- [ ] The Fiscal Times
- [ ] The Daily Beast
- [ ] https://futurism.com/
- [ ] Curbed
- [ ] Recode
- [ ] Eater
- [ ] SB Nation
- [ ] Racked
- ~~Drudge Report~~
- ~~Huff Po~~
- ~~Vox~~
- ~~Slate~~
- ~~Breitbart~~

- [ ] 100 best blogs 2015 https://dailytekk.com/the-100-best-most-interesting-blogs-and-websites-of-2015/?reading=continue
- [ ] Panda and click + Add feeds http://usepanda.com/app/#/

global research  http://www.globalresearch.ca/
https://www.rt.com/news/
https://sputniknews.com/
http://en.farsnews.com/allstories.aspx
paul craig roberts  http://www.paulcraigroberts.org/
consortium news https://consortiumnews.com/
http://theduran.com/
antiwar.com  http://www.antiwar.com/
counterpunch  http://www.counterpunch.org/
information clearinghouse  http://www.informationclearinghouse.info/
new eastern outlook  http://journal-neo.org/

http://katehon.com/
https://www.lewrockwell.com/
http://www.moonofalabama.org/
http://thesaker.is/
http://www.veteransnewsnow.com/
http://www.veteransnewsnow.com/
http://wearechange.org/
http://www.zerohedge.com/
SOTN - http://stateofthenation2012.com/
