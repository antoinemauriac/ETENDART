import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-student"
export default class extends Controller {

  static targets = [ "form", "list", "input" ]
  // static values = { url: String }

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
}
