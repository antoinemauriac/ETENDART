import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {

  static targets = [ "navbar", "navbarCollapse", "navbarToggle" ]
  // Connects to data-action="click->navbar#toggle"
  connect() {
  }

  displayMenu() {
    this.navbarTarget.classList.toggle('show');
    this.navbarCollapseTarget.classList.toggle('show');
    this.navbarToggleTarget.classList.toggle('active')
  }
}
