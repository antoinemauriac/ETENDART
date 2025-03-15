import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form--children--select-check"
export default class extends Controller {

  static targets = [ "card, checkbox" ]

  connect() {
    console.log("ceci est pour le formulaire");
  }

  toggle(event) {
    console.log(event.currentTarget);

    const card = event.currentTarget;
    const checkbox = card.querySelector('input[type="checkbox"]');

    checkbox.checked = !checkbox.checked;
    card.classList.toggle('border');
    card.classList.toggle('border-black');
    card.classList.toggle('shadow');
  }
}
