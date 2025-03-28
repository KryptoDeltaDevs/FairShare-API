# FairShare API

API to store and retrieve groups information

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/group/`: returns all group IDs
- GET `api/v1/group/[:id]`: returns details about a single group with given ID
- POST `api/v1/group/`: creates a new group

## Install

Install this API by cloning the _relevant branch_ and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
puma
```
