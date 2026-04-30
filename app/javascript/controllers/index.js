import { Application } from "@hotwire/stimulus"
import { autoload } from "@hotwire/stimulus-autoloader"

const application = Application.start()
application.debug = false
window.Stimulus = application
eagerLoadControllersFrom(application)