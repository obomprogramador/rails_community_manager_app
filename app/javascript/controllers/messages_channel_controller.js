import { Controller } from "@hotwire/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = { communityId: Number }

  connect() {
    this.subscription = consumer.subscriptions.create(
      {
        channel: "CommunityMessagesChannel",
        community_id: this.communityIdValue
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
    if (data.type === "new_message") {
      // Turbo Stream já cuida do DOM se vier do server-side broadcast
      // Este bloco é fallback para broadcast via JS puro
      const list = document.getElementById("messages_list")
      if (list) {
        const li = document.createElement("li")
        li.textContent = data.message.content
        list.appendChild(li)
      }
    }
  }
}