import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clickable-table"
export default class extends Controller {

  static targets = ["clickable"]

  connect() {
    this.clickableTargets.forEach((row) => {
      row.addEventListener('click', (event) => {
        const target = event.target;
        if (target.classList.contains('trash') || target.classList.contains('btn-add-student') || target.classList.contains('fa-edit')) {
          return;
        }
        window.location.href = row.getAttribute('data-url');
      });
    });
  }
}
