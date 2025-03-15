import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap";

// Connects to data-controller="form--children--modal"
export default class extends Controller {
  static targets = ["modal"];

  connect() {
    this.modal = new Modal(this.modalTarget, { keyboard: false });
    this.modal.show();
  }
}
