import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap";

// Connects to data-controller="close-modal"
export default class extends Controller {

  closeModal() {

    // Ciblez la modal et fermez-la
    const modalElement = document.getElementById(this.element.id); // Utilise l'ID pour trouver la modal
    console.log(modalElement);

    if (modalElement) {
      const modalInstance = bootstrap.Modal.getInstance(modalElement);
      if (modalInstance) {
        modalInstance.hide();
      }
    }
  }
}
