import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "sportActivity", "eveilActivity", "soutienActivity", "errorMessage"]

  connect() {
    this.submitButtonTargets.forEach(button => {
      button.disabled = true
    })
    this.validateForm()
  }

  validateForm() {
    const sportSelected = this.sportActivityTargets.some(checkbox => checkbox.checked)
    const eveilSelected = this.eveilActivityTargets.some(checkbox => checkbox.checked)

    // Vérifier si des activités de soutien scolaire sont présentes
    const hasSoutienActivities = this.soutienActivityTargets.length > 0
    let soutienSelected = true // Par défaut valide si pas d'activités de soutien

    if (hasSoutienActivities) {
      // Si des activités de soutien sont présentes, vérifier qu'une option est sélectionnée
      soutienSelected = this.soutienActivityTargets.some(radio => radio.checked)
    }

    const isValid = sportSelected && eveilSelected && soutienSelected

    this.submitButtonTargets.forEach(button => {
      button.disabled = !isValid
    })

    // Adapter le message d'erreur selon les champs manquants
    if (!isValid) {
      let errorMessage = "Veuillez sélectionner "
      const missingFields = []

      if (!sportSelected) missingFields.push("une activité sport")
      if (!eveilSelected) missingFields.push("une activité éveil")
      if (hasSoutienActivities && !soutienSelected) missingFields.push("une option pour le soutien scolaire")

      if (missingFields.length === 1) {
        errorMessage += missingFields[0]
      } else if (missingFields.length === 2) {
        errorMessage += missingFields[0] + " et " + missingFields[1]
      } else {
        errorMessage += missingFields.slice(0, -1).join(", ") + " et " + missingFields.slice(-1)
      }

      this.errorMessageTarget.textContent = errorMessage
    }

    this.errorMessageTarget.classList.toggle('d-none', isValid)
  }
}
