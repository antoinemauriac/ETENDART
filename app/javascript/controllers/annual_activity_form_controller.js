import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["category", "coach", "subform", "ageRanges", "errorMessage", "submitButton"]

  static values = { academyId: Number }

  connect() {
    this.coachTargets.forEach((coachTarget) => {
      if (!coachTarget._tomSelect) {
        coachTarget._tomSelect = new TomSelect(coachTarget, {
          plugins: ['remove_button'],
        });
      }
    });

    // Ajouter des listeners pour tous les champs de temps
    this.addTimeListeners();
  }

  addTimeListeners() {
    // Écouter les changements sur tous les champs de temps Rails
    const timeFields = document.querySelectorAll('select[name="activity[day_attributes][start_time(4i)]"], select[name="activity[day_attributes][start_time(5i)]"], select[name="activity[day_attributes][end_time(4i)]"], select[name="activity[day_attributes][end_time(5i)]"]');
    timeFields.forEach(field => {
      field.addEventListener('change', () => this.validateTimes());
    });
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

  // Méthode commune pour récupérer les champs de temps et calculer les minutes
  getTimeFieldsAndMinutes() {
    const startHourField = document.querySelector('select[name="activity[day_attributes][start_time(4i)]"]');
    const startMinuteField = document.querySelector('select[name="activity[day_attributes][start_time(5i)]"]');
    const endHourField = document.querySelector('select[name="activity[day_attributes][end_time(4i)]"]');
    const endMinuteField = document.querySelector('select[name="activity[day_attributes][end_time(5i)]"]');

    if (!startHourField || !startMinuteField || !endHourField || !endMinuteField) {
      return null;
    }

    const startHours = parseInt(startHourField.value) || 0;
    const startMinutes = parseInt(startMinuteField.value) || 0;
    const endHours = parseInt(endHourField.value) || 0;
    const endMinutes = parseInt(endMinuteField.value) || 0;

    const startTotalMinutes = startHours * 60 + startMinutes;
    const endTotalMinutes = endHours * 60 + endMinutes;

    return {
      startTotalMinutes,
      endTotalMinutes,
      isValid: startTotalMinutes < endTotalMinutes
    };
  }

  validateTimes() {
    const timeData = this.getTimeFieldsAndMinutes();

    if (!timeData) return;

    if (timeData.isValid) {
      this.hideError();
      this.enableSubmit();
    } else {
      this.showError("L'heure de début doit être avant l'heure de fin");
      this.disableSubmit();
    }
  }

  validateForm(event) {
    const timeData = this.getTimeFieldsAndMinutes();

    if (!timeData) return true;

    if (!timeData.isValid) {
      event.preventDefault();
      this.showError("L'heure de début doit être avant l'heure de fin");
      return false;
    }

    return true;
  }

  showError(message) {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = message;
      this.errorMessageTarget.classList.remove("d-none");
    }
  }

  hideError() {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.classList.add("d-none");
    }
  }

  disableSubmit() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true;
      this.submitButtonTarget.classList.add("btn-disabled");
    }
  }

  enableSubmit() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false;
      this.submitButtonTarget.classList.remove("btn-disabled");
    }
  }
}
