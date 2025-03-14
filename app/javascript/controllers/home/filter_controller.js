import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home--filter"
export default class extends Controller {

  static targets = [ "academy" ]
  connect() {
    console.log("ceci est pour la homepage");
  }

  filter(event) {
    console.log("ca filtre");

    const selectedAcademy = event.target.dataset.academyId;

    this.academyTargets.forEach(academy => {
      if (academy.dataset.academyId === selectedAcademy || selectedAcademy === "all") {
        academy.classList.remove("d-none");
      } else {
        academy.classList.add("d-none");
      }
    });
  }


}
