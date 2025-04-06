import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {

  static targets = [ "navbar", "navbarCollapse", "navbarToggle", "badge" ]
  // Connects to data-action="click->navbar#toggle"

  displayMenu() {
    this.navbarCollapseTarget.classList.toggle('show');
    this.navbarToggleTarget.classList.toggle('active');
    this.badgeTarget.classList.toggle('d-none')
  }

  closeMenu() {
    this.navbarCollapseTarget.classList.toggle('show')
    this.navbarToggleTarget.classList.toggle('active')
    this.badgeTarget.classList.toggle('d-none')
  }
}
