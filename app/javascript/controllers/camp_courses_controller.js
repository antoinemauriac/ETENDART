import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="camp-courses"
export default class extends Controller {
  static targets = ["table", "button", "header"];

  connect() {
    this.showMore = true;
  }

  toggleTable() {
    this.showMore = !this.showMore;
    this.tableTargets.forEach(table => {
      table.classList.toggle("show-more", this.showMore);
    })
    this.buttonTargets.forEach(button => {
      button.textContent = this.showMore ? "Voir +" : "Voir -";
    });

    if (this.showMore) {
      // Scroll to the top of the table when "Voir -" is clicked
      this.headerTarget.scrollIntoView({ behavior: "smooth" });
    }
  }
}
