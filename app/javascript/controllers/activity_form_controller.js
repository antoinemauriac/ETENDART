import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["startTime", "endTime", "mondayStartTime", "mondayEndTime", "category", "coach"]

  connect() {
    console.log("zozo ");
    this.mondayStartTimeTarget.value = "10:00";
    this.mondayEndTimeTarget.value = "12:00";
    this.startTimeTargets.forEach((input) => (input.value = "10:00"));
    this.endTimeTargets.forEach((input) => (input.value = "12:00"));
    this.coachTargets.forEach(coachTarget => {
        new TomSelect(coachTarget, {
          plugins: ['remove_button'],
        })
      })
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
    const category_id = this.categoryTarget.value
    const academy_id = this.categoryTarget.dataset.academyId
    const url = `/managers/coaches/${category_id}/category_coaches?academy_id=${academy_id}`

    fetch(url)
      .then(response => response.json())
      .then(coaches => {
        this.coachTargets.forEach(coachTarget => {
          let tomSelect = coachTarget.tomselect
          tomSelect.options =
            coaches.map (coach => {
            return {value: coach.id, text: `${coach.first_name} ${coach.last_name}`}
          })
          tomSelect.options.push({value: coaches[0].id, text: `${coaches[0].first_name} ${coaches[0].last_name}`})
        })
      })

  }

  onCategoryChange() {
    this.loadCoaches()
  }
}
