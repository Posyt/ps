# Posyt Scraper

The Posyt news scraper


## Development

Just run:

```
./s
```


## Deployment

Just push to master and Heroku will take it from there

If you update a mongo index run:

```
heroku run rake db:mongoid:create_indexes
```
