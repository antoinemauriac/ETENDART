import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload-photo"
export default class extends Controller {
  static targets = ["photo", "spinner", "form"];

  connect() {
    console.log("test");
    const image = this.photoTarget;
    if (image.complete) {
      this.spinnerTarget.classList.add("d-none");
    } else {
      image.addEventListener("load", () => {
        this.spinnerTarget.classList.add("d-none");
        this.formTarget.classList.remove("d-none");
      });
    }
    this.formTarget.addEventListener("change", (event) => {
      event.preventDefault();
      this.showSpinner();
    });
  }

  showSpinner() {
    console.log("submitting form");
    this.spinnerTarget.classList.remove("d-none");
    this.photoTarget.classList.add("d-none");
    // this.formTarget.submit();
  }
}

// function submitForm() {
//   document.getElementById("spinner").classList.remove('d-none');
//   document.getElementById("student-photo-manager").classList.add('d-none');
//   document.getElementById("upload_form").submit();
// }

// var image = document.getElementById("student-photo-manager");
// if (image.complete) {
//   document.getElementById("spinner").classList.add('d-none');
// } else {
//   image.addEventListener("load", function() {
//     document.getElementById("spinner").classList.add('d-none');
//     document.getElementById("photo-input").classList.remove('d-none');
//   });
// }
