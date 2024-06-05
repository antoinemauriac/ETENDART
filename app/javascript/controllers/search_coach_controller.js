import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "form", "list", "input" ]

  connect() {
    console.log("hello darling");
  }

  update() {
    const academy_id = this.inputTarget.dataset.academyId
    const query = this.inputTarget.value
    const url = `coaches?academy=${academy_id}&query=${query}`;
    fetch(url, {headers: {"Accept": "text/plain"}})
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data
      })
  }
}
