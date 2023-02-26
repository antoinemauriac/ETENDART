import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("PresenceSheetController connected");
    const checkboxes = this.element.querySelectorAll(
      ".presence-sheet-form input[type='checkbox']"
    );
    checkboxes.forEach((checkbox) => {
      const statusTexts = checkbox.parentElement.querySelectorAll(
        ".status-text"
      );
      checkbox.addEventListener("change", () => {
        statusTexts.forEach((statusText) => {
          statusText.classList.toggle("d-none");
        });
      });
    });
  }
}
