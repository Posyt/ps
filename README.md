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
- [ ] Deep Dot Web
- [ ] HBR
- [ ] Wired
- [ ] The Onion
- [ ] Aeon.co
- [ ] xkcd
- [ ] Academia.edu
- [ ] arXiv
- [ ] NASA - PubSpace https://www.ncbi.nlm.nih.gov/pmc/funder/nasa/
- [ ] TODO: scrape book recommendations, ideally freely available books
- [ ] Upworthy
- [ ] TODO: find scientific journals with good free access papers
- [ ] First Round Review
- [ ] Science Mag
- [ ] Science Daily
- [ ] The Atlantic
- [ ] Politico Magazine
- [ ] Buzzfeed
- [ ] Polygon
- [ ] PewResearchCenter
- [ ] Gallup
- [ ] The Next Web
- [ ] Github Trending
- [ ] Designer News
- [ ] Reddit
- [ ] Trend Hunter
- [ ] The Economist
- [ ] Behance
- [ ] SoundCloud
- [ ] YouTube
- [ ] Twitch
- [ ] HypeMachine
- [ ] The Daily Beast
- [ ] Niice.co
- [ ] AP
- [ ] Reuters
- [ ] The Fiscal Times
- ~~Drudge Report~~
- ~~Huff Po~~
- ~~Vox~~
- ~~Slate~~
- ~~Breitbart~~

- [ ] 100 best blogs 2015 https://dailytekk.com/the-100-best-most-interesting-blogs-and-websites-of-2015/?reading=continue
- [ ] Panda and click + Add feeds http://usepanda.com/app/#/
