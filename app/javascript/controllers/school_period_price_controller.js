import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="school-period-price"
export default class extends Controller {

  static targets = ["paidTrue", "paidFalse", "price"]

  connect() {
    console.log("Connected to school-period-price controller");

    this.togglePriceRequired()
  }

  togglePriceRequired() {
    console.log("togglePriceRequired called");

    if (this.paidTrueTarget.checked) {
      this.priceTarget.required = true
    } else {
      this.priceTarget.required = false
    }
  }
}
