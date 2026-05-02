import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["options"]

  toggle() {
    this.optionsTarget.classList.toggle("hidden")
  }
}