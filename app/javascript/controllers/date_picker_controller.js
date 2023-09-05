import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr";

// Connects to data-controller="date-picker"
export default class extends Controller {
  connect() {
    this.initializeDatePicker();
    console.log("Hello, Flatpickr");
  }

  disconnect() {
    // Cleanup any remaining flatpickr instances to avoid memory leaks
    if (this.fp) {
      this.fp.destroy();
      this.fp = null;
    }
  }

  initializeDatePicker() {
    // You can pass in any flatpickr options you'd like here, or customize it however you need
    this.fp = flatpickr(this.element, {
      altInput: true,
      altFormat: "F j, Y",
      dateFormat: "Y-m-d"
    });
  }
}
