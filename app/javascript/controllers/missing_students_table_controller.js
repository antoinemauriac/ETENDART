import { Controller } from "@hotwired/stimulus"
import $ from 'jquery';
import "datatables.net"

// Connects to data-controller="missing-students-table"
export default class extends Controller {
  connect() {
    console.log("Controller connected");
    $(document).ready(function() {
      console.log("Document ready");
      const table = $('#missing-students').DataTable({
        ordering: false,
        paging: false,
        info: false,
        language: {
          search: '',
          searchPlaceholder: 'Rechercher...',
          zeroRecords: 'Aucun résultat',
        },
      });
      console.log("DataTable initialized", table);
    });
  }
}
