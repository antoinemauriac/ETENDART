import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="enrollment-form"
export default class extends Controller {
  static targets = ["academy", "schoolPeriod", "camp", "activity"];

  updateSchoolPeriods() {
    const academy_id = this.academyTarget.value
    const url = `/managers/enrollments/${academy_id}/update_school_periods`

    fetch(url)
      .then(response => response.json())
      .then(schoolPeriods => {
        this.schoolPeriodTarget.innerHTML = ''
        this.schoolPeriodTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        schoolPeriods.forEach(schoolPeriod => {
          const option = document.createElement('option')
          option.value = schoolPeriod.id
          option.textContent = `${schoolPeriod.full_name}`
          console.log(option.textContent);
          this.schoolPeriodTarget.appendChild(option)
        })
      })
  }

  updateCamps() {
    const school_period_id = this.schoolPeriodTarget.value
    const url = `/managers/enrollments/${school_period_id}/update_camps`

    fetch(url)
      .then(response => response.json())
      .then(camps => {
        this.campTarget.innerHTML = ''
        this.campTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        camps.forEach(camp => {
          const option = document.createElement('option')
          option.value = camp.id
          option.textContent = `${camp.name}`
          this.campTarget.appendChild(option)
        })
      })
  }

  updateActivities() {
    const camp_id = this.campTarget.value
    const url = `/managers/enrollments/${camp_id}/update_activities`

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
