# Wabi

Ruby framework from scratch

## Local Installation

### Clone Github repo and install Ruby gems:

```
bundle install
```

### Launch server

`rackup`

### Run the tests to know everthing is working fine:

`bundle exec rspec`

### Start with docker:

```
docker build -t wabi.1.0.0 .
docker run -p 9292:9292 wabi.1.0.0
```
