import { Controller } from "@hotwire/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static values = { messageId: Number }

  connect() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "MessageReactionsChannel",
        message_id: this.messageIdValue
      },
      {
        received: (data) => this.handleReceived(data)
      }
    )
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }

  handleReceived(data) {
    // O Turbo Stream atualiza o DOM automaticamente
    console.log("Reaction update:", data)
  }
}