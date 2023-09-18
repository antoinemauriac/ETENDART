import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="past-camp-courses"
export default class extends Controller {
  static targets = ["table", "button", "header"];

  connect() {
    console.log("past camp courses connected");
    this.showMore = true;
  }

  toggleTable() {
    this.showMore = !this.showMore;
    this.tableTarget.classList.toggle("show-more", this.showMore);
    this.buttonTarget.textContent = this.showMore ? "Voir +" : "Voir -";

    if (this.showMore) {
      // Scroll to the top of the table when "Voir -" is clicked
      this.headerTarget.scrollIntoView({ behavior: "smooth" });
    }
  }
}
