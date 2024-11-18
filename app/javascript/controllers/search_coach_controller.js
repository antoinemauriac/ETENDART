import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [ "list", "input" ]

  static values = { academyId: Number }

  update() {
    const academy_id = this.academyIdValue
    const query = this.inputTarget.value
    const url = `coaches?academy=${academy_id}&query=${query}`;
    fetch(url, {headers: {"Accept": "text/plain"}})
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data
      })
  }
}
