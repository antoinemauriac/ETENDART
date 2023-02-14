import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {

    document.addEventListener('DOMContentLoaded', () => {
      const selectors = document.querySelectorAll('select');
      const tableRows = document.querySelectorAll('tbody tr');

      document.querySelector('#clear-filters').addEventListener('click', () => {
        selectors.forEach((selector) => {
          selector.value = '';
        });
        tableRows.forEach((row) => {
          row.style.display = 'table-row';
        });
      });

      selectors.forEach((selector) => {
        selector.addEventListener('change', () => {
          const nameFilter = document.querySelector('#filter-name').value;
          const dayFilter = document.querySelector('#filter-day').value;
          const startFilter = document.querySelector('#filter-start-time').value;
          const endFilter = document.querySelector('#filter-end-time').value;

          tableRows.forEach((row) => {
            const name = row.querySelector('td:nth-child(1)').innerText;
            const day = row.querySelector('td:nth-child(2)').innerText;
            const start = row.querySelector('td:nth-child(3)').innerText;
            const end = row.querySelector('td:nth-child(4)').innerText;

            if (
              (!nameFilter || name.indexOf(nameFilter) !== -1) &&
              (!dayFilter || day.indexOf(dayFilter) !== -1) &&
              (!startFilter || start.indexOf(startFilter) !== -1) &&
              (!endFilter || end.indexOf(endFilter) !== -1)
            ) {
              row.style.display = 'table-row';
            } else {
              row.style.display = 'none';
            }
          });
        });
      });
    });
  }
}
