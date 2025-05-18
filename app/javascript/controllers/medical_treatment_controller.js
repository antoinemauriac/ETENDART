import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="medical-treatment"
export default class extends Controller {
  static targets = ["hasMedicalTreatment", "description", "submitButton", "descriptionContainer"];
  connect() {
    const hasMedicalTreatment = this.hasMedicalTreatmentTargets.find(input => input.checked)?.value === "true";

    if (hasMedicalTreatment) {
      this.descriptionTarget.required = true;
      this.descriptionContainerTarget.classList.remove("d-none");
    }
  }

  toggleDescriptionRequirement() {
    const hasMedicalTreatment = this.hasMedicalTreatmentTargets.find(input => input.checked)?.value === "true";

    if (hasMedicalTreatment) {
      this.descriptionTarget.required = true;
      this.descriptionContainerTarget.classList.remove("d-none");
    } else {
      this.descriptionTarget.required = false;
      this.descriptionContainerTarget.classList.add("d-none");
      this.descriptionTarget.value = "";
    }
  }

  validateForm(event) {
    const hasMedicalTreatment = this.hasMedicalTreatmentTargets.find(input => input.checked)?.value === "true";
    const description = this.descriptionTarget.value.trim();

    if (hasMedicalTreatment && description === "") {
      event.preventDefault();
      alert("Veuillez fournir une description du traitement médical.");
    }
  }


}
