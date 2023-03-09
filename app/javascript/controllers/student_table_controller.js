import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import "datatables.net"

export default class extends Controller {

  connect() {
    console.log('pipa');
    if ($('#myTable_wrapper').length === 0 ) {
      $('#myTable').DataTable({
        searchable: true,
        ordering: true,
        paging: true,
        select: true,
        lengthMenu: [10, 15, 20, 50, 400],
        pageLength: 50,
        language: {
          search: '',
          searchPlaceholder: 'Rechercher...',
          lengthMenu: 'Afficher _MENU_ lignes par page',
          zeroRecords: 'Aucun résultat',
          info: "Affichage de la page _PAGE_ sur _PAGES_",
          infoEmpty: 'Affichage de 0 à 0 sur 0 lignes',
          infoFiltered: '',
          paginate: {
            first: 'Premier',
            last: 'Dernier',
            next: 'Suivant',
            previous: 'Précédent',
          }
        },
        columnDefs: [
          { orderable: true, targets: [0] },
        ],
        "table": {
          "className": "border-0"
        },
        initComplete: function () {
          this.api()
            .columns()
            .every(function () {
              var column = this;
              var select = $('<select><option value=""></option></select>')
                .appendTo( $(column.header()) )
                .addClass('form-select')
                .on('change', function () {
                  var val = $.fn.dataTable.util.escapeRegex($(this).val());
                  column.search(val ? '^' + val + '$' : '', true, false).draw();
                });

              $( select ).on('click', function(e) {
                    e.stopPropagation();
              });

              column.cells('', column[0]).render('display').sort().unique().each( function ( d, j ) {
                select.append( '<option value="'+d+'">'+d+'</option>' )
              } );
            });

          // Création de la div pour envelopper les éléments en en-tête
          const tableWrapper = $('#myTable_wrapper');
          const tableHeader = tableWrapper.find('.dataTables_scrollHeadInner table');
          const searchInput = tableWrapper.find('.dataTables_filter input');
          const lengthSelect = tableWrapper.find('.dataTables_length');
          const tableHeaderDiv = $('<div class="container table-header-student d-flex align-items-center justify-content-between mt-1"></div>');
          const clearFilterButton = $('<button class="btn btn-outline-secondary btn-clear ms-2">Clear Filter</button>');

          const selectLength = lengthSelect.children().eq(0).children().eq(0);
          selectLength.addClass('select-length');

          // Ajout de la div avant le tableau
          tableWrapper.prepend(tableHeaderDiv);

          // Déplacement des éléments dans la div créée
          tableHeaderDiv.append(clearFilterButton);
          tableHeaderDiv.append(searchInput);
          tableHeaderDiv.append(lengthSelect);


          // Au clic sur le bouton, réinitialiser les filtres et vider le champ de recherche
          clearFilterButton.on('click', function () {
            const table = $('#myTable').DataTable();
            table.search('').columns().search('').draw();
            $('.dataTables_filter input').val('');

            // Parcourir tous les éléments select et les réinitialiser
            $('.form-select').each(function() {
              $(this).val('');
            });
          });
        },
      });
    }
  }
}



      // const datanames = ['academie', 'nom', 'prenom', 'genre', 'datenaissance'];
      // const selects = {};
      // const selectValues = {};

      // datanames.forEach(function(name) {
      //   const query = `[data-name="${name}"] select`;
      //   selects[name] = document.querySelector(query);
      //   selectValues[name] = '';
      // });

      // const dataArrays = {};
      // for (let i = 0; i < datanames.length; i++) {
      //   const dataArray = $('#myTable').DataTable().column(i).data().toArray();
      //   dataArrays[datanames[i]] = dataArray;
      // }

      // Object.values(selects).forEach(function(select) {
      //   select.addEventListener('change', function() {
      //     const selectedOptionValue = $(this).val()
      //     const columnName = select.parentElement.dataset.name;
      //     const columnIndex = datanames.indexOf(columnName);

      //     selectValues[columnName] = selectedOptionValue;
      //     console.log(Object.values(selectValues));

      //     Object.keys(dataArrays).forEach(function(columnName) {
      //       const filteredValues = dataArrays[columnName].filter(function(value, index, self) {
      //         const correspondingSelectValue = dataArrays[datanames[columnIndex]][index];
      //         const selectedValues = Object.values(selectValues);
      //         const valueIsSelected = selectedValues.includes(correspondingSelectValue);
      //         return valueIsSelected && self.indexOf(value) === index;
      //       });

      //       const select = selects[columnName];
      //       if (select === this) return;
      //       select.innerHTML = '';
      //       select.innerHTML += `<option value=""></option>`;
      //       filteredValues.forEach(function(value) {
      //         select.innerHTML += `<option value="${value}">${value}</option>`;
      //       });
      //     });
      //   });
      // });
