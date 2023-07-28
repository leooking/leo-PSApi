# https://github.com/docker-library/ruby/blob/cdac1ffbc959768a5b82014dbb8c8006fe6f7880/2.7/alpine3.16/Dockerfile
FROM ruby:2.7.7-alpine3.16 as builder

RUN apk update && apk upgrade

# troubleshooting "Error loading shared library ld-linux-x86-64.so.2"
#   issue is between alpine and grpc
#   lead to adding gcompat most recently added
RUN apk add --update tzdata libpq-dev alpine-sdk gcompat nodejs busybox nano && \
  rm -rf /var/cache/apk/*

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/
ENV RAILS_ENV=production

RUN bundle config set without development test
RUN bundle install --jobs 4

COPY . ./

# final stage of build
FROM ruby:2.7.7-alpine3.16

RUN apk update && apk add --update tzdata libpq-dev && rm -rf /var/cache/apk/* 

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY --from=builder /app $APP_HOME
COPY --from=builder /usr/local/bundle /usr/local/bundle

ENV RAILS_ENV=production

# cloud run port
EXPOSE 8080
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
