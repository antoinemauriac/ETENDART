import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

// Connects to data-controller="cart--warning-modal"
export default class extends Controller {
  connect() {
    const modal = new Modal(this.element)
    modal.show()
  }
}
