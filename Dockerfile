FROM ruby:2.4.9

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get update -qq && apt-get install -yq build-essential nodejs

RUN mkdir /app
WORKDIR /app
ADD . /app
RUN bundle install
