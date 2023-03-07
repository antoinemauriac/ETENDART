import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clicklable-table"
export default class extends Controller {
  connect() {
    console.log('clicklable-table controller connected');
    document.querySelectorAll('.clickable-tr').forEach((row) => {
      row.addEventListener('click', (event) => {
        const target = event.target;
        console.log(target);
        if (target.classList.contains('fa-trash')) {
          return; // Ajout du return ici pour empêcher l'exécution du reste de la fonction
        }
        window.location.href = row.getAttribute('data-url');
      });
    });
  }
}
