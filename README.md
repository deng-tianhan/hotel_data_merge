# README

This README document steps necessary to get the application up and running.

## Ruby version
```sh
$ ruby --version
ruby 3.3.3
```

## System dependencies
```sh
$ sqlite3 --version
3.46.0
```
```sh
$ rails --version
Rails 7.1.3.4
```
Install gem file dependencies
```sh
$ bundle
```

## Database creation
```sh
$ rails db:create
```

## Database initialization
```sh
$ rails db:setup
```

## How to run the test suite
```sh
$ bundle exec rspec
```
After running the tests, open `coverage/index.html` in the browser to check test coverage details.

For more FE heavy projects we could also setup automated regression tests. (The author previously used cucumber + capybara + selenium.)

## Start Server
On Windows: may need to run as administrator
```sh
$ rails server
```
Listening on `http://127.0.0.1:3000` or `http://localhost:3000` by default.
The landing page shows the list of all hotels in the DB, along with some helper functions.

## Search Hotels by destination and id
You can search by passing your query params to `/search`
It accepts `hotels` and/or `destination`
- `/search?hotels=iJhz,f8c9`
- `/search?destination=5432`

To view the response in json format, pass params to `/api/search` instead
It is similar to `/search`
- `/api/search?hotels=iJhz,f8c9&destination=5432`

The `hotels` param also accepts json string
- `/api/search?hotels=["iJhz","f8c9"]`

## Decisions on data cleaning & selecting the best data

### Data cleaning
Check `app\models\concerns\data_cleaning.rb` as a starting place.
Abstract methods are implemented in `Hotel`, `Amenity`, and `Image` models.
In addition `Hotel` has some method wrappers, which does additional handling after calling the original method.

### Selecting the best data
Check `app\models\concerns\data_merging.rb`, which contains the relevant logic extracted from `Hotel` model.

Stores broken images but removes them when rendering the frontend.
Check `app\helpers\hotels_helper.rb#remove_broken_images`
Broken image url: `https://d2ey9sqrvkqdfs.cloudfront.net/0qZF/6.jpg`

## Performance Decisions

### Procuring the data
Try to find existing records in DB first and update them, instead of Rails default: delete & create new associations.

For large data set this could be moved to rabbitmq + consumer.

### Delivering the data
Only query `hotels` table once, regardless of how many parameters provided