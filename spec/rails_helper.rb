require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models',      'app/models'
  add_group 'Use Cases',   'app/lib/clean_arch'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.

require 'factory_bot_rails'
require 'database_cleaner/active_record'

module RequestSessionHelper
  def sign_in(user)
    post '/session', params: { username: user.username }, as: :json
  end
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Config Selenium
  config.before(:each, type: :feature, js: true) do
    Capybara.current_driver = :selenium_chrome_remote

    # Isso garante que o servidor Puma use a mesma conexão de banco que o teste
    # permitindo que o usuário criado pelo FactoryBot seja visível para o Selenium
    ActiveRecord::ConnectionAdapters::ConnectionPool.class_eval do
      def current_thread_id
        Thread.main.object_id
      end
    end
  end

  config.after(:each, type: :feature, js: true) do
    Capybara.use_default_driver
  end

  config.before(:each, type: :feature) do
    # Garante que as conexões sejam compartilhadas entre threads se necessário
    # No Rails 7+ isso geralmente é tratado, mas em Docker ajuda forçar
    ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.before(:each, type: :feature, js: true) do
  #   self.use_transactional_tests = false
  # end

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  
  # Limpa o contador de uniqueness do Faker entre testes
  config.after(:each) do
    Faker::UniqueGenerator.clear
  end

  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include RequestSessionHelper, type: :request
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

class ActiveRecord::Base
  mattr_accessor :shared_connection
  def self.connection
    @@shared_connection || retrieve_connection
  end
end
