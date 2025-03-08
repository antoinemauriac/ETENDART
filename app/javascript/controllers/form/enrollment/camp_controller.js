import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["camp", "sportActivities", "eveilActivities"]

  connect() {
    const campId = this.element.id.split('_')[1]
    this.handleActivitySelections(campId)
  }

  toggle(event) {
    this.campTarget.classList.toggle("d-none", !event.target.checked)
  }

  handleActivitySelections(campId) {
    // Gérer les activités sportives pour ce camp spécifique
    this.sportActivitiesTargets.forEach(checkbox => {
      checkbox.type = 'radio'
      checkbox.name = `camp_id[${campId}][sport_activity_id]`
    })

    // Gérer les activités d'éveil pour ce camp spécifique
    this.eveilActivitiesTargets.forEach(checkbox => {
      checkbox.type = 'radio'
      checkbox.name = `camp_id[${campId}][eveil_activity_id]`
    })
  }
}
