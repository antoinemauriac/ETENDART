import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import "datatables.net"

export default class extends Controller {

  connect() {
    console.log("TITI");
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
