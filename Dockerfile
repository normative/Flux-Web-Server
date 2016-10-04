FROM ruby:2.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
        nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/flux_app
COPY Gemfile* ./
RUN bundle install
COPY . .

EXPOSE 3101
ENV RAILS_ENV development
CMD ["rails", "server", "-b", "0.0.0.0"]
