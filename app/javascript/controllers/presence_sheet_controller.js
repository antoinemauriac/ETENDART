import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll(".form-switch-input").forEach((checkbox) => {
      checkbox.addEventListener("change", () => {
        const statusText = checkbox.closest("tr").querySelector(".status-text");
        statusText.classList.toggle("d-none");
      });
    });
  }
}
