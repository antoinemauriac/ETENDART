import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-student"
export default class extends Controller {

  static targets = [ "form", "list", "input", "select", "link", "paginationLink" ]
  static values = { academyId: Number }

  connect() {
    if (this.hasSelectTarget) {
      this.setInitialAcademySelection();
    }
  }

  setInitialAcademySelection() {
    const params = new URLSearchParams(window.location.search);
    const academy_id = params.get('academy');

    if (academy_id) {
      this.selectTarget.value = academy_id;
    }
  }

  update() {
    const academy_id = this.academyIdValue
    const query = this.inputTarget.value
    const url = `students?academy=${academy_id}&query=${query}`;
    fetch(url, {headers: {"Accept": "text/plain"}})
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data
        this.hideDuplicatePaginations();
      })
  }

  update_for_admin() {
    const query = this.inputTarget.value;
    const academy_id = this.selectTarget.value;

    this.linkTarget.href = `/managers/students/export_students_csv.csv?academy=${academy_id}`;

    const url = new URL(window.location.href);
    url.searchParams.set('query', query);
    url.searchParams.set('academy', academy_id);
    url.searchParams.delete('page'); // Reset pagination to the first page

    fetch(url.toString(), { headers: { "Accept": "text/plain" } })
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data;
        this.updatePaginationLinks(academy_id, query);
        this.hideDuplicatePaginations();
      });
  }

  updatePaginationLinks(academy_id, query) {
    this.paginationLinkTargets.forEach(link => {
      const url = new URL(link.href)
      url.searchParams.set('academy', academy_id)
      url.searchParams.set('query', query)
      link.href = url.toString()
    })
  }

  hideDuplicatePaginations() {
    const paginations = document.querySelectorAll('.pagy-list');
    if (paginations.length > 1) {
      paginations.forEach((pagination, index) => {
        if (index > 0) {
          pagination.style.display = 'none';
        }
      });
    }
  }
}
