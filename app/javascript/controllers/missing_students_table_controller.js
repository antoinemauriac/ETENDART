import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import "datatables.net"

// Connects to data-controller="missing-students-table"
export default class extends Controller {
  connect() {
    $(document).ready(function() {
      $('#missing-students').DataTable({
        ordering: false,
        paging: false,
        info: false,
        language: {
          search: '',
          searchPlaceholder: 'Rechercher...',
          zeroRecords: 'Aucun résultat',
        },
      });
    });
  }
}
