import { Application } from "@hotwire/stimulus"
import { autoload } from "@hotwire/stimulus-autoloader"

import ReactionToggleController from "./reaction_toggle_controller"

const application = Application.start()
application.register("reaction-toggle", ReactionToggleController)
application.debug = false
window.Stimulus = application

autoload(application)