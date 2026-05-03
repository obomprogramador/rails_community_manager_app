import { Application } from "@hotwire/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

import ReactionToggleController from "./reaction_toggle_controller"
application.register("reaction-toggle", ReactionToggleController)