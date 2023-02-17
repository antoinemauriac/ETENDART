import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const selectors = document.querySelectorAll('select');
    const tableRows = document.querySelectorAll('tbody tr');
    const filters = ['name', 'day', 'start-time', 'end-time'];

    const clearFilters = () => {
      selectors.forEach((selector) => {
        selector.value = '';
      });
      tableRows.forEach((row) => {
        row.style.display = 'table-row';
      });
    };

    const applyFilters = () => {
      tableRows.forEach((row) => {
        let showRow = true;
        filters.forEach((filter) => {
          const filterValue = document.querySelector(`#filter-${filter}`).value;
          if (filterValue !== '') {
            const rowValue = row.querySelector(`td:nth-child(${filters.indexOf(filter) + 1})`).innerText;
            if (rowValue.indexOf(filterValue) === -1) {
              showRow = false;
            }
          }
        });
        if (showRow) {
          row.style.display = 'table-row';
        } else {
          row.style.display = 'none';
        }
      });
    };

    document.querySelector('#clear-filters').addEventListener('click', clearFilters);
    selectors.forEach((selector) => selector.addEventListener('change', applyFilters));
  }
}
