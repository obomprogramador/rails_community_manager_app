pin "application", preload: true
pin "@hotwire/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwire/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwire/stimulus-autoloader", to: "stimulus-autoloader.min.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"