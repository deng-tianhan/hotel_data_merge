# README

This README document steps necessary to get the application up and running.

## Ruby version
```sh
ruby --version
```
ruby 3.3.3

## System dependencies
```sh
sqlite3 --version
```
sqlite3 3.46.0

```sh
rails --version
```
Rails 7.1.3.4

### Install gem file dependencies
```sh
bundle
```

## Database creation
```sh
rails db:create
```

## Database initialization
```sh
rails db:setup
```

## How to run the test suite
```sh
bundle exec rspec
```
After running the tests, open `coverage/index.html` in the browser to check test coverage details.

For more FE heavy projects we could also setup automated regression tests. (The author previously used cucumber + capybara + selenium.)

## Start Server
On Windows: may need to run as administrator
```sh
rails server
```
Listening on `http://127.0.0.1:3000` or `http://localhost:3000` by default.

The landing page shows the list of all hotels in the DB, along with some helper functions.

## Search Hotels by destination and id
You can search by passing your query params to `/search`

It accepts `hotels` and/or `destination`
```
/search?hotels=iJhz,f8c9
```
```
/search?destination=5432
```

To view the response in json format, pass params to `/api/search` instead

It is similar to `/search`
```
/api/search?hotels=iJhz,f8c9&destination=5432
```

The `hotels` param also accepts json string
```
/api/search?hotels=["iJhz","f8c9"]
```

## Decisions on data cleaning & selecting the best data

### Data cleaning
Strip spaces and store keys in lowercase. Check `data_cleaner.rb` for details.

### Selecting the best data
Check `app\models\concerns\data_merging.rb`, which contains the relevant logic extracted from `Hotel` model.

Use `upsert_all` with `unique_by` to merge amenities and images efficiently. Check `batch_query_manager.rb` for details.

Stores broken images but removes them when rendering the frontend.
- Check `app\helpers\hotels_helper.rb#remove_broken_images`
- Broken image url: `https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg`

## Performance Decisions

### Procuring the data
Eager load to avoid n+1 queries.

Batch upsert records to reduce number of DB writes.

For large data set this could be moved to rabbitmq + consumer.

### Delivering the data
Eager load to avoid n+1 queries.
