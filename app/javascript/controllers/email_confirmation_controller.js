import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["email", "emailConfirmation", "message", "warning"];

  checkConfirmation() {
    const email = this.emailTarget.value;
    const emailConfirmation = this.emailConfirmationTarget.value;

    if (emailConfirmation === "") {
      this.messageTarget.textContent = "";
      return;
    }

    if (email !== emailConfirmation) {
      this.messageTarget.textContent = "Les emails ne correspondent pas.";
      this.messageTarget.style.color = "red";
    } else {
      this.messageTarget.textContent = "";
    }

  }
}