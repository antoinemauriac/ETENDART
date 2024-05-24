import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-student"
export default class extends Controller {

  static targets = [ "form", "list", "input", "select", "link" ]
  // static values = { url: String }

  connect() {
    console.log("Connected to search student controller");
  }


  update() {
    const academy_id = this.inputTarget.dataset.academyId
    const query = this.inputTarget.value
    console.log(academy_id);
    console.log(query);
    const url = `students?academy=${academy_id}&query=${query}`;
    console.log(url);
    fetch(url, {headers: {"Accept": "text/plain"}})
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data
      })
  }

  update_for_admin() {
    const query = this.inputTarget.value
    const academy_id = this.selectTarget.value

    this.linkTarget.href = `/managers/students/export_students_csv.csv?academy=${academy_id}`;
    console.log(this.linkTarget.href);

    const url = `index_for_admin?query=${query}&academy=${academy_id}`;
    fetch(url, { headers: { "Accept": "text/plain" } })
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data
      })
  }
}
