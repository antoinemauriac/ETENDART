import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden-forms"
export default class extends Controller {
  connect() {
    console.log("hello from controller")

    // School Period Form
    const addSchoolPeriodBtn = document.getElementById("add-school-period-btn");
    const cancelSchoolPeriodBtn = document.getElementById("cancel-school-period-btn");
    const schoolPeriodForm = document.getElementById("school-period-form");

    if (addSchoolPeriodBtn) {
      addSchoolPeriodBtn.addEventListener("click", function(event) {
        event.preventDefault();
        schoolPeriodForm.classList.remove("hidden-form");
      });
      cancelSchoolPeriodBtn.addEventListener("click", function(event) {
        event.preventDefault();
        schoolPeriodForm.classList.add("hidden-form");
      });
    }

    // Camp FORM
    const addCampBtn = document.getElementById("add-camp-btn");
    const cancelCampBtn = document.getElementById("cancel-camp-btn");
    const campForm = document.getElementById("camp-form");

    if (addCampBtn) {
      addCampBtn.addEventListener("click", function(event) {
        console.log("hello");
        event.preventDefault();
        campForm.classList.remove("hidden-form");
      });
      cancelCampBtn.addEventListener("click", function(event) {
        event.preventDefault();
        campForm.classList.add("hidden-form");
      });
    }

    // category FORM
    const addCategoryBtn = document.getElementById("add-category-btn");
    const cancelCategoryBtn = document.getElementById("cancel-category-btn");
    const categoryForm = document.getElementById("category-form");

    if (addCategoryBtn) {
      addCategoryBtn.addEventListener("click", function(event) {
        console.log("hello");
        event.preventDefault();
        categoryForm.classList.remove("hidden-form");
      });
      cancelCategoryBtn.addEventListener("click", function(event) {
        event.preventDefault();
        categoryForm.classList.add("hidden-form");
      });
    }

    // location FORM
    const addLocationBtn = document.getElementById("add-location-btn");
    const cancelLocationBtn = document.getElementById("cancel-location-btn");
    const locationForm = document.getElementById("location-form");

    if (addLocationBtn) {
      addLocationBtn.addEventListener("click", function(event) {
        console.log("hello");
        event.preventDefault();
        locationForm.classList.remove("hidden-form");
      });
      cancelLocationBtn.addEventListener("click", function(event) {
        event.preventDefault();
        locationForm.classList.add("hidden-form");
      });
    }
  }
}
