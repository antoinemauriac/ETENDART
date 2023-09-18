import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="annual-enrollments-form"
export default class extends Controller {
  static targets = ["academy", "annualProgram", "activity"];

  connect() {

  }

  updateAnnualPrograms() {
    const academy_id = this.academyTarget.value
    const url = `/managers/annual_enrollments/${academy_id}/update_annual_programs`

    fetch(url)
      .then(response => response.json())
      .then(annualPrograms => {
        this.annualProgramTarget.innerHTML = ''
        this.annualProgramTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        annualPrograms.forEach(annualProgram => {
          const option = document.createElement('option')
          option.value = annualProgram.id
          option.textContent = `${annualProgram.start_year} - ${annualProgram.end_year}`
          this.annualProgramTarget.appendChild(option)
        })
      })
  }

  updateActivities() {
    const annual_program_id = this.annualProgramTarget.value
    console.log(annual_program_id);
    const url = `/managers/annual_enrollments/${annual_program_id}/update_activities`

    fetch(url)
      .then(response => response.json())
      .then(activities => {
        this.activityTarget.innerHTML = ''
        this.activityTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        activities.forEach(activity => {
          const option = document.createElement('option')
          option.value = activity.id
          option.textContent = `${activity.name}`
          this.activityTarget.appendChild(option)
        })
      })
  }
}
