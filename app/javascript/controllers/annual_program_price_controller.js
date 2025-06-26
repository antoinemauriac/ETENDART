import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="annual-program-price"
export default class extends Controller {

  static targets = ["paidTrue", "paidFalse", "price"]

  connect() {
    console.log("Connected to annual-program-price controller");
    this.togglePriceRequired()
  }

  togglePriceRequired() {
    console.log("togglePriceRequired called");

    if (this.paidTrueTarget.checked) {
      this.priceTarget.style.display = "block"
      this.priceTarget.querySelector('input').required = true
    } else {
      this.priceTarget.style.display = "none"
      this.priceTarget.querySelector('input').required = false
    }
  }
}
