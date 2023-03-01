import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startTime", "endTime", "mondayStartTime", "mondayEndTime", "category", "coach"]

  connect() {
    console.log("test ");
    this.mondayStartTimeTarget.value = "10:00";
    this.mondayEndTimeTarget.value = "12:00";
    this.startTimeTargets.forEach((input) => (input.value = "10:00"));
    this.endTimeTargets.forEach((input) => (input.value = "12:00"));
  }

  onMondayStartTimeInputChange(event) {
    console.log("onMondayStartTimeInputChange");
    const mondayStartTime = this.mondayStartTimeTarget.value;
    this.startTimeTargets.forEach((input) => (input.value = mondayStartTime))
  }

  onMondayEndTimeInputChange(event) {
    const mondayEndTime = this.mondayEndTimeTarget.value

    this.endTimeTargets.forEach((input) => (input.value = mondayEndTime))
  }

  loadCoaches() {
    const categoryId = this.categoryTarget.value
    const url = `/managers/coaches/${categoryId}/category_coaches`

    fetch(url)
      .then(response => response.json())
      .then(coaches => {
        this.coachTarget.innerHTML = ''
        this.coachTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        coaches.forEach(coach => {
          const option = document.createElement('option')
          option.value = coach.id
          option.textContent = `${coach.first_name} ${coach.last_name}`
          this.coachTarget.appendChild(option)
        })
      })
  }

  onCategoryChange() {
    this.loadCoaches()
  }
}
