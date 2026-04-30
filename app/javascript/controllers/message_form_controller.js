import { Controller } from "@hotwire/stimulus"

export default class extends Controller {
  static targets = ["content", "submit"]

  submit(event) {
    // Previne nova linha no Enter (Shift+Enter permite)
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }

  reset() {
    this.contentTarget.value = ""
    this.contentTarget.focus()
  }
}