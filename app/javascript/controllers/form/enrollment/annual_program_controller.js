import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sportActivities", "eveilActivities", "soutienActivities"]

  connect() {
    this.handleActivitySelections()
  }

  handleActivitySelections() {
    // Gérer les activités sportives
    this.sportActivitiesTargets.forEach(checkbox => {
      checkbox.type = 'radio'
      checkbox.name = 'annual_program_enrollment[sport_activity_id]'
    })

    // Gérer les activités d'éveil
    this.eveilActivitiesTargets.forEach(checkbox => {
      checkbox.type = 'radio'
      checkbox.name = 'annual_program_enrollment[eveil_activity_id]'
    })

    // Gérer les activités de soutien scolaire
    this.soutienActivitiesTargets.forEach(radio => {
      radio.name = 'annual_program_enrollment[soutien_activity_id]'
    })
  }
}
