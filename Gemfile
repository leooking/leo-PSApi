source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.7"

gem 'rails', '~> 7.0', '>= 7.0.4'
gem 'pg', '~> 1.4', '>= 1.4.5'
gem 'puma', '~> 6.0'

gem 'activeadmin', '~> 2.13', '>= 2.13.1'
gem 'acts-as-taggable-on', '~> 9.0', '>= 9.0.1'
gem 'argon2', '~> 2.1', '>= 2.1.2'
gem 'audited', '~> 5.0', '>= 5.0.2'
gem 'awesome_nested_set', '~> 3.5'
gem "bootsnap", require: false
gem 'devise', '~> 4.8', '>= 4.8.1'
gem 'google-cloud-storage', '~> 1.44'

# Working on heinous net-http issues by adding this gem
# Installing this in Gemfile eliminated errors on rails s / c
# See https://github.com/ruby/net-imap/issues/16
gem 'net-http', '~> 0.3.2'

gem 'faraday', '~> 2.7', '>= 2.7.2'
gem 'faraday-retry', '~> 2.1'
gem 'jwt', '~> 2.5'
gem 'kaminari', '~> 1.2', '>= 1.2.2'
gem 'oj', '~> 3.13', '>= 3.13.23'
gem 'pg_search', '~> 2.3', '>= 2.3.6'
gem 'public_suffix', '~> 5.0', '>= 5.0.1'
gem 'qdrant-ruby', '~> 0.9.0'
gem 'rack-cors', '~> 1.1', '>= 1.1.1'
gem 'sass-rails', '~> 6.0'
gem 'stripe', '~> 8.5'
gem 'tzinfo', '~> 2.0', '>= 2.0.5'
gem 'tzinfo-data', '~> 1.2022', '>= 1.2022.7'
gem 'nokogiri', '~> 1.14', '>= 1.14.2'
# gem 'stackdriver', '~> 0.21.1'

gem 'smarter_csv', '~> 1.7', '>= 1.7.3'
gem 'seedbank', '~> 0.5.0'
gem 'sprockets', '~> 4.1', '>= 4.1.1' # for activeadmin
gem 'tokenizer', '~> 0.3.0'

gem 'rotp', '~> 6.2', '>= 6.2.2'
gem 'otp', '~> 0.0.11'

group :development, :test do
  gem 'byebug', '~> 11.1', '>= 11.1.3'
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'dotenv-rails', '~> 2.8', '>= 2.8.1'
  gem 'rubocop'
  gem 'rubocop-ast'
end

group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller', '~> 1.0'
  gem 'letter_opener', '~> 1.8', '>= 1.8.1'
  gem 'letter_opener_web', '~> 2.0'
end
