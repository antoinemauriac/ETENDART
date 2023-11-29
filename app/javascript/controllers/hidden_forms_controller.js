import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden-forms"
export default class extends Controller {

  static targets = [ "feedbackForm", "schoolPeriodForm", "campForm", "categoryForm", "locationForm" ]

  connect() {
    console.log("test")
  }

  // School Period Form
  displaySchoolPeriodForm() {
    this.schoolPeriodFormTarget.classList.toggle("show");
    this.schoolPeriodFormTarget.classList.toggle("add-padding");
  };

  hideSchoolPeriodForm() {
    this.schoolPeriodFormTarget.classList.remove("show");
    this.schoolPeriodFormTarget.classList.remove("add-padding");
  };
  // Camp Form
  displayCampForm() {
    this.campFormTarget.classList.toggle("show");
    this.campFormTarget.classList.toggle("add-padding");
  };

  hideCampForm() {
    this.campFormTarget.classList.remove("show");
    this.campFormTarget.classList.remove("add-padding");
  };

  // Category Form
  displayCategoryForm() {
    this.categoryFormTarget.classList.toggle("show");
    this.categoryFormTarget.classList.toggle("add-padding");
  };

  hideCategoryForm() {
    this.categoryFormTarget.classList.remove("show");
    this.categoryFormTarget.classList.remove("add-padding");
  };

  // Location Form
  displayLocationForm() {
    this.locationFormTarget.classList.toggle("show");
    this.locationFormTarget.classList.toggle("add-padding");
  };

  hideLocationForm() {
    this.locationFormTarget.classList.remove("show");
    this.locationFormTarget.classList.remove("add-padding");
  };

  // Feedback Form
  displayFeedbackForm() {
    this.feedbackFormTarget.classList.toggle("show");
    this.feedbackFormTarget.classList.toggle("add-margin-and-padding");
  }
  hideFeedbackForm() {
    this.feedbackFormTarget.classList.remove("show");
    this.feedbackFormTarget.classList.remove("add-margin-and-padding");
  }
}
