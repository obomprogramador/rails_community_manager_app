# spec/support/capybara.rb
require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.default_max_wait_time = 10

# FORÇAR DETECÇÃO: Verifica variáveis comuns de ambiente Docker/CI
is_docker = ENV['DOCKER'] == 'true' || ENV['CI'] || ENV['RACK_ENV'] == 'test'
# is_docker = ENV['DOCKER'] == 'true'

if is_docker
  puts "🚀 [INFO] Detectado ambiente Docker/CI. Configurando Selenium Remoto (Chrome)."
  
  Capybara.register_driver :selenium_chrome_remote do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1920,1080')
    
    # URL do serviço Selenium no Docker Compose
    # O nome do serviço no docker-compose.yml é 'selenium'
    selenium_url = "http://selenium:4444/wd/hub"
    
    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: selenium_url,
      options: options
    )
  end

  Capybara.app = Rails.application
  
  Capybara.javascript_driver = :selenium_chrome_remote
  
  # Dentro da rede Docker, o Rails se chama 'web'
  Capybara.server_host = '0.0.0.0'
  Capybara.server_port = 3000
  Capybara.app_host = 'http://web:3000'
  Capybara.server = :puma, { Silent: false }
  
else
  puts "🏃 [INFO] Ambiente Local. Configurando Selenium Local (Chrome)."
  
  Capybara.register_driver :selenium_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
  
  Capybara.javascript_driver = :selenium_chrome
  Capybara.app_host = 'http://localhost:3000'
end