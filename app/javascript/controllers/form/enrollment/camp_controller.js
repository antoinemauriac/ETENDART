import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form--enrollment--camp"
export default class extends Controller {

  static targets = [ "camp" ]
  connect() {
  }

  toggle() {
    this.campTarget.classList.toggle("d-none");
  }
}
