# Posyt Scraper

The Posyt news scraper


## Development

In the terminal
```
./s
```

In a separate rails console (Only run this on initial configuration to create the index)
```
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
- [ ] Science Mag
- [ ] Science Daily
- [ ] Kotaku
- [ ] Polygon
- [ ] HBR
- [ ] Github Trending
- [ ] Designer News
- [ ] Reddit
- [ ] Wired
- [ ] Huff Po
- [ ] Buzzfeed
- [ ] Vox
- [ ] Bloomberg
- [ ] The Onion
- [ ] Deep Dot Web
- [ ] Behance
