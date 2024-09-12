import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clickable-table"
export default class extends Controller {

  static targets = ["clickable"]

  connect() {
    console.log('hello from clickable table controller');
    this.clickableTargets.forEach((row) => {
      row.addEventListener('click', (event) => {
        const target = event.target;
        if (target.classList.contains('trash')) {
          return; // Ajout du return ici pour empêcher l'exécution du reste de la fonction
        }
        window.location.href = row.getAttribute('data-url');
      });
    });
  }
}
