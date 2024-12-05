import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["photo", "spinner", "form"];
  static values = { studentId: Number};

  connect() {
    this.formTarget.addEventListener("change", event => this.submitForm(event));
  }

  showSpinner() {
    this.spinnerTarget.classList.remove("d-none");
    this.photoTarget.classList.add("d-none");
  }

  submitForm(event) {
    console.log('submitForm');
    console.log(this.studentIdValue);


    event.preventDefault();

    this.showSpinner();

    const formData = new FormData(this.formTarget);
    const url = `/managers/students/${this.studentIdValue}/update_photo`
    fetch(url, {
      method: 'PUT',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data => {
      this.spinnerTarget.classList.add("d-none");
      this.photoTarget.classList.remove("d-none");
      this.photoTarget.src = `${data.imageUrl}?timestamp=${new Date().getTime()}`;
    })
    .catch(error => {
      console.error('Error:', error);
    });
  }
}
