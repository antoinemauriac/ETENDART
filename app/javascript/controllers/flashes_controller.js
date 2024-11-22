import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flashes"
export default class extends Controller {
  static targets = ["alert"]

  connect() {
    this.alertTargets.forEach((alert) => {
      setTimeout(() => {
        alert.classList.remove("show")
        setTimeout(() => {
          alert.classList.add("d-none")
        }, 500)
      }, 4000)
    })
  }
}
