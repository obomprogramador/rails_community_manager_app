import { Controller } from "@hotwire/stimulus"

export default class extends Controller {
  static targets = ["options"]

  toggle() {
    this.optionsTarget.classList.toggle("hidden")
  }
}