import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["startTime", "endTime", "mondayStartTime", "mondayEndTime", "category", "coach", "subform", "ageRanges", "errorMessage", "submitButton"]

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

    // Ajouter des listeners pour valider les horaires
    this.addTimeListeners();

    // Ajouter un listener pour valider avant soumission
    this.addFormSubmitListener();
  }

  addTimeListeners() {
    // Écouter les changements sur tous les champs de temps
    const timeFields = document.querySelectorAll('input[type="time"]');
    timeFields.forEach(field => {
      field.addEventListener('change', () => this.validateTimes());
    });

    // Écouter les changements sur les checkboxes des jours
    const dayCheckboxes = document.querySelectorAll('input[type="checkbox"][name*="day_of_week"]');
    dayCheckboxes.forEach(checkbox => {
      checkbox.addEventListener('change', () => this.validateTimes());
    });
  }

  addFormSubmitListener() {
    const form = this.element.querySelector('form');
    if (form) {
      form.addEventListener('submit', (event) => {
        if (!this.validateForm()) {
          event.preventDefault();
        }
      });
    }
  }

  validateTimes() {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];
    let hasErrors = false;

    days.forEach(day => {
      const checkbox = document.querySelector(`input[type="checkbox"][value="${day}"]`);

      if (checkbox && checkbox.checked) {
        const startTimeField = document.querySelector(`input[name*="start_time_${day}"]`);
        const endTimeField = document.querySelector(`input[name*="end_time_${day}"]`);

        if (startTimeField && endTimeField && startTimeField.value && endTimeField.value) {
          const startTime = startTimeField.value;
          const endTime = endTimeField.value;

          // Convertir en minutes pour comparaison
          const startMinutes = this.timeToMinutes(startTime);
          const endMinutes = this.timeToMinutes(endTime);

          if (startMinutes >= endMinutes) {
            this.markFieldAsError(startTimeField);
            this.markFieldAsError(endTimeField);
            hasErrors = true;
          } else {
            this.clearFieldError(startTimeField);
            this.clearFieldError(endTimeField);
          }
        }
      }
    });

    if (hasErrors) {
      this.showError("L'heure de début doit être antérieure à l'heure de fin pour tous les jours sélectionnés.");
      this.disableSubmit();
    } else {
      this.hideError();
      this.enableSubmit();
    }

    return !hasErrors;
  }

  validateForm() {
    return this.validateTimes();
  }

  timeToMinutes(timeString) {
    const [hours, minutes] = timeString.split(':').map(Number);
    return hours * 60 + minutes;
  }

  markFieldAsError(field) {
    field.style.borderColor = '#dc3545';
  }

  clearFieldError(field) {
    field.style.borderColor = '';
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

  onMondayStartTimeInputChange(event) {
    const mondayStartTime = this.mondayStartTimeTarget.value;
    this.startTimeTargets.forEach((input) => (input.value = mondayStartTime));
    // Valider après changement
    setTimeout(() => this.validateTimes(), 100);
  }

  onMondayEndTimeInputChange(event) {
    const mondayEndTime = this.mondayEndTimeTarget.value;
    this.endTimeTargets.forEach((input) => (input.value = mondayEndTime));
    // Valider après changement
    setTimeout(() => this.validateTimes(), 100);
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
