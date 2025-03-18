import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {

  static targets = [ "navbar", "navbarCollapse", "navbarToggle" ]
  // Connects to data-action="click->navbar#toggle"

  displayMenu() {
    this.navbarCollapseTarget.classList.toggle('show');
    this.navbarToggleTarget.classList.toggle('active')
  }

  closeMenu() {
    this.navbarCollapseTarget.classList.remove('show')
    this.navbarToggleTarget.classList.remove('active')
  }
}
