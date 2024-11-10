import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["startTime", "endTime", "mondayStartTime", "mondayEndTime", "category", "coach", "subform"]

  connect() {
    this.mondayStartTimeTarget.value = "10:00";
    this.mondayEndTimeTarget.value = "12:00";
    this.startTimeTargets.forEach((input) => (input.value = "10:00"));
    this.endTimeTargets.forEach((input) => (input.value = "12:00"));
    this.coachTargets.forEach((coachTarget) => {
      if (!coachTarget._tomSelect) {
        coachTarget._tomSelect = new TomSelect(coachTarget, {
          plugins: ['remove_button'],
        });
      }
    });
  }

  onMondayStartTimeInputChange(event) {
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
          const tomSelect = coachTarget._tomSelect;
          tomSelect.clearOptions();
          tomSelect.addOption(coaches.map(coach => ({ value: coach.id, text: `${coach.first_name} ${coach.last_name}` })));
        })
      })
  }

  onCategoryChange() {
    this.subformTarget.classList.remove("d-none");
    this.loadCoaches();
  }
}
