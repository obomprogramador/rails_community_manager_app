import { Controller } from "@hotwire/stimulus"

export default class extends Controller {
  static targets = ["input", "submit", "error"]

  validate(event) {
    const username = this.inputTarget.value.trim()
    this.clearError()

    if (!username) {
      event.preventDefault()
      this.showError("Informe o nome de usuário.")
      this.inputTarget.focus()
      return
    }

    // Evita duplo submit enquanto a requisição está indo
    this.submitTarget.disabled = true
    this.submitTarget.textContent = "Entrando..."
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
  }

  clearError() {
    this.errorTarget.textContent = ""
    this.errorTarget.hidden = true
  }
}