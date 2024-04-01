import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="update-photo-from-course"
export default class extends Controller {
  static targets = ["input", "spinner", "studentPhoto", "label"];

  connect() {
  }

  submit(event) {
    console.log("submit");
    this.spinnerTarget.classList.remove("d-none");
    this.labelTarget.classList.add("d-none");
    let studentId = event.target.dataset.studentId;
    const url = `/managers/students/${studentId}/update_photo`
    const formData = new FormData();
    const origin = event.target.dataset.origin;
    formData.append("student[photo]", event.target.files[0]);
    formData.append("origin", origin);
    const csrfToken = document.querySelector("[name='csrf-token']").getAttribute("content");

    fetch(url, {
      method: "PUT",
      headers: {
        'X-CSRF-Token':csrfToken,
        'Accept': 'text/plain'
      },
      body: formData,
      credentials: "include"
    })
    .then(response => response.text())
    .then(data => {
      this.studentPhotoTarget.outerHTML = data;
    })
  }
}
