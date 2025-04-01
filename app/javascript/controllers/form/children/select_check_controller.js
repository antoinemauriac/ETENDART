import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form--children--select-check"
export default class extends Controller {

  static targets = [ "card", "checkbox", "submitButton", "helperMessage", "buttonOverlay" ]

  connect() {
    this.updateSubmitButton()
  }

  toggle(event) {
    const card = event.currentTarget
    const checkbox = card.querySelector('input[type="checkbox"]')

    checkbox.checked = !checkbox.checked
    card.classList.toggle('parent-bg')
    // card.classList.toggle('border-black')
    card.classList.toggle('shadow')
    
    this.updateSubmitButton()
    this.helperMessageTarget.classList.add('d-none')
  }

  updateSubmitButton() {
    const checkedBoxes = this.checkboxTargets.filter(checkbox => checkbox.checked)
    if (checkedBoxes.length === 0) {
      this.buttonOverlayTarget.classList.remove('d-none')
    } else {
      this.buttonOverlayTarget.classList.add('d-none')
    }
  }

  showHelper(event) {
    event.preventDefault()
    this.helperMessageTarget.classList.remove('d-none')
  }
}
