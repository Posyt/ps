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

- [ ] fix imgur - nothing is getting scraped
- [ ] fix product hunt - not scraping much

- [x] Dribble
- [x] Hacker News
- [x] Imgur
- [x] New York Times
- [x] Product Hunt
- [x] The Verge
- [ ] Medium
- [ ] Vice
- [ ] Upworthy
- [ ] TODO: find scientific journals with good free access papers
- [ ] First Round Review
- [ ] Science Mag
- [ ] Science Daily
- [ ] The Atlantic
- [ ] Kotaku
- [ ] Buzzfeed
- [ ] Polygon
- [ ] PewResearchCenter
- [ ] The Onion
- [ ] Bloomberg
- [ ] HBR
- [ ] Github Trending
- [ ] Designer News
- [ ] Reddit
- [ ] Wired
- [ ] Huff Po
- [ ] Vox
- [ ] The Economist
- [ ] Deep Dot Web
- [ ] Behance
- [ ] Drudge Report
- [ ] SoundCloud
- [ ] YouTube
- [ ] HypeMachine
