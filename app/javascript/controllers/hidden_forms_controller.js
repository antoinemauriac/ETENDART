import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden-forms"
export default class extends Controller {

  static targets = [ "feedbackForm", "schoolPeriodForm", "campForm", "categoryForm", "locationForm" ]

  // School Period Form
  displaySchoolPeriodForm() {
    this.schoolPeriodFormTarget.classList.toggle("show");
  };

  // Camp Form
  displayCampForm() {
    this.campFormTarget.classList.toggle("show");
  };

  // Category Form
  displayCategoryForm() {
    this.categoryFormTarget.classList.toggle("show");
  };

  // Location Form
  displayLocationForm() {
    this.locationFormTarget.classList.toggle("show");
  };

  // Feedback Form
  displayFeedbackForm() {
    this.feedbackFormTarget.classList.toggle("show");
    // this.feedbackFormTarget.classList.toggle("add-margin-and-padding");
  }
}
