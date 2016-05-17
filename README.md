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


## Deployment

Just push to master and Heroku will take it from there

If you update a mongo index run:

```
heroku run rake db:mongoid:create_indexes
```

## TODO

http://ctrlq.org/rss/
https://www.rsssearchhub.com/

- [ ] Medium
- [ ] Vice
- [ ] Upworthy
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
