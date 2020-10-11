FROM ruby:2.7.1

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . /app/
WORKDIR /app
EXPOSE 9292

CMD ["rackup", "--host", "0.0.0.0", "-p", "9292"]
