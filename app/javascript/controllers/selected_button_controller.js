import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="selected-button"
export default class extends Controller {

  static targets = [ "button" ]

  connect() {

  }

  toggleButtons(event) {
    this.buttonTargets.forEach((button) => {
      button.classList.remove('selected')
    })
    event.currentTarget.classList.add('selected')
  }
}
