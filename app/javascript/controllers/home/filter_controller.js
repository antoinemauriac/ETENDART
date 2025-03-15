import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home--filter"
export default class extends Controller {

  static targets = [ "academy", "button" ]
  connect() {
    console.log("ceci est pour la homepage");
  }

  filter(event) {
    this.buttonTargets.forEach(button => {
      if (button === event.currentTarget) {
        button.classList.add("bg-white");
        button.classList.remove("bg-secondary");
      } else {
        button.classList.add("bg-secondary");
        button.classList.remove("bg-white");
      }
    });


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
