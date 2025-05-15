# FairShare API

API to store and retrieve groups information

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/group/`: returns all group IDs
- GET `api/v1/group/[:id]`: returns details about a single group with given ID
- POST `api/v1/group/`: creates a new group

## Install

Install this API by cloning the _relevant branch_ and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
ruby spec
```

## Develop/Debug

Add fake data to the development database to work on this project:

```shell
rake db:seed
```

## Execute

Launc this API using:

```shell
puma
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release_check
```
