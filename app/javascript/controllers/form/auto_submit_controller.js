import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form--auto-submit"
export default class extends Controller {
  connect() {
    console.log("hello from form--auto-submit controller")
  };

  // auto submit a form when a radio button is changed
  submit() {
    this.element.requestSubmit()
  }
}
