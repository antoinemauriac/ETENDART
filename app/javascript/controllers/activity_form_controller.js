import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["startTime", "endTime", "mondayStartTime", "mondayEndTime", "category", "coach", "subform", "ageRanges"]

  static values = { academyId: Number }

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
    const academy_id = this.academyIdValue
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

  addRanges() {
    if (this.ageRangesTarget.innerHTML.trim() === "") {
      this.ageRangesTarget.innerHTML = `
        <div class="mb-3" data-age-fields>
          <label for="activity_min_age" class="form-label">Age minimum</label>
          <input type="number" name="activity[min_age]" id="activity_min_age" class="form-control activity-input" min="0" required="required">

          <label for="activity_max_age" class="form-label mt-3">Age maximum</label>
          <input type="number" name="activity[max_age]" id="activity_max_age" class="form-control activity-input" min="0" required="required">
        </div>
      `;
    }
  }

  removeRanges() {
    this.ageRangesTarget.innerHTML = "";
  }
    
}
