import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "campCheckbox", "errorMessage"]

  connect() {
    this.submitButtonTargets.forEach(button => {
      button.disabled = true
    })
    this.validateForm()
  }

  validateForm() {
    const selectedCamps = this.campCheckboxTargets.filter(checkbox => checkbox.checked)
    let isValid = true

    if (selectedCamps.length === 0) {
      isValid = false
    } else {
      selectedCamps.forEach(campCheckbox => {
        const campSection = campCheckbox.closest('section')
        const sportActivities = campSection.querySelectorAll('input[name$="[sport_activity_id]"]')
        const eveilActivities = campSection.querySelectorAll('input[name$="[eveil_activity_id]"]')
        
        const sportSelected = Array.from(sportActivities).some(input => input.checked)
        const eveilSelected = Array.from(eveilActivities).some(input => input.checked)

        if (!sportSelected || !eveilSelected) {
          isValid = false
        }
      })
    }

    this.submitButtonTargets.forEach(button => {
      button.disabled = !isValid
    })
    this.errorMessageTarget.classList.toggle('d-none', isValid)
  }
}
