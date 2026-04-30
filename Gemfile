source "https://rubygems.org"

ruby "3.2.4"

# Rails
gem "rails", "~> 7.2.0"

# Banco
gem "pg", "~> 1.5"

# Server
gem "puma", "~> 6.4"

# Hotwire
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Views
gem "haml-rails"

# JSON
gem "jbuilder"

# Performance
gem "bootsnap", require: false

gem "simplecov", require: false
gem 'sprockets-rails'
gem 'globalid', '>= 1.2.1'

group :development, :test do
  gem "debug", platforms: [:mri]

  # RSpec
  gem "rspec-rails", "~> 8.0"

  gem 'pry'
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :development do
  gem "html2haml"
  gem "web-console"
  gem "listen"
  gem "spring"
end

group :test do
  # Ferramentas úteis com RSpec
  gem "factory_bot_rails"
  gem "faker"
  gem "capybara"
  gem "selenium-webdriver"
end