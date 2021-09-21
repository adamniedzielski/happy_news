FROM ruby:3.0.0-alpine AS dev
RUN apk add build-base postgresql-dev tzdata
WORKDIR /happy_news
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

FROM dev AS ci
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . ./

FROM dev AS productionn
COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment --without test development
COPY . ./
