import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import "datatables.net"

export default class extends Controller {


  connect() {
    console.log('zozo');
    if ($('#myTable_wrapper').length === 0 ) {
      $('#myTable').DataTable({
        searchable: true,
        ordering: true,
        paging: true,
        select: true,
        lengthMenu: [10, 15, 20, 50, 400],
        pageLength: 15,
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
