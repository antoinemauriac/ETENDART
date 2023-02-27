import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("toto");
    const selectors = document.querySelectorAll('select');
    const tableRows = document.querySelectorAll('tbody tr');
    const filters = ['name', 'day', 'start-time', 'end-time'];
    const columns = tableRows[0].querySelectorAll('td');

    const clearFilters = () => {
      selectors.forEach((selector) => {
        selector.value = '';
      });
      tableRows.forEach((row) => {
        row.style.display = 'table-row';
        row.classList.remove('present');
      });
      for (let i = 0; i < columns.length; i++) {
        const columnSelect = document.getElementById(`filter-${filters[i]}`);
        const columnOptions = Array.from(columnSelect.options);
        columnOptions.forEach((option) => {
          option.hidden = false;
        });
      }
    };

    const applyFilters = () => {
      console.log("c'est parti");
      tableRows.forEach((row) => {
        let showRow = true;
        for (let i = 0; i < columns.length; i++) {
          const filterValue = document.querySelector(`#filter-${filters[i]}`).value;
          if (filterValue !== '') {
            const rowValue = row.querySelector(`td:nth-child(${i + 1})`).innerText;
            if (rowValue.indexOf(filterValue) === -1) {
              showRow = false;
            }
          }
        }
        if (showRow) {
          row.style.display = 'table-row';
          row.classList.add('present');
        } else {
          row.style.display = 'none';
          row.classList.remove('present');
        }
      });

      for (let i = 0; i < columns.length; i++) {
        const columnSelect = document.getElementById(`filter-${filters[i]}`);
        const selectedValues = Array.from(document.querySelectorAll('.present td:nth-child(' + (i+1) + ')')).map(value => value.innerText);
        const columnOptions = Array.from(columnSelect.options);
        columnOptions.forEach((option) => {
          if (option.value === '') {
            option.hidden = false;
          } else if (selectedValues.includes(option.innerText)) {
            option.hidden = false;
          } else {
            option.hidden = true;
          }
        });
      }
    };

    document.querySelector('#clear-filters').addEventListener('click', clearFilters);
    selectors.forEach((selector) => selector.addEventListener('change', applyFilters));

        // Récupération de l'élément input de recherche
    var input = document.getElementById("searchInput");

    // Ajout d'un écouteur d'événement pour la saisie de l'utilisateur
    input.addEventListener("keyup", function() {
      applyFilters();
      // Récupération de la valeur saisie dans l'input
      var filter = input.value.toUpperCase();
      // Récupération de l'élément tbody du tableau
      var tableBody = document.getElementsByTagName("tbody")[0];
      // Récupération de toutes les lignes du tableau
      var rows = tableBody.getElementsByTagName("tr");

      // Boucle sur toutes les lignes du tableau
      for (var i = 0; i < rows.length; i++) {
        // Récupération de toutes les cellules de la ligne
        var cells = rows[i].getElementsByTagName("td");
        var found = false;
        // Boucle sur toutes les cellules de la ligne
        for (var j = 0; j < cells.length; j++) {
          var cell = cells[j];
          // Vérification si la valeur de la cellule contient la valeur saisie
          if (cell.innerHTML.toUpperCase().indexOf(filter) > -1) {
            found = true;
            break;
          }
        }
        // Affichage ou masquage de la ligne en fonction de la correspondance
        if (found) {
          rows[i].style.display = "";
        } else {
          rows[i].style.display = "none";
        }
      }
    });
  }
}
