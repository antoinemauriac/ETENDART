import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payment-method"
export default class extends Controller {
  static targets = ["receiver"]

  toggleReceiverRequired(event) {
    const paymentMethod = event.target.value
    if (paymentMethod === "cheque" || paymentMethod === "cash" || paymentMethod === "offert") {
      this.receiverTarget.required = true
    } else {
      this.receiverTarget.required = false
    }
  }
}
