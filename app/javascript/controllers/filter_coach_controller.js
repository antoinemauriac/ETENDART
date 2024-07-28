import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter-coach"
export default class extends Controller {

  static targets = [ "list" ]

  updateList(event) {
    const coach_id = event.currentTarget.value;
    const url = `/managers/finances/membership_finances_overview?coach=${coach_id}`;
    console.log(coach_id);
    fetch(url, {headers: {"Accept": "text/plain"}})
      .then(response => response.text())
      .then((data) => {
        this.listTarget.outerHTML = data
      })
  }
}
