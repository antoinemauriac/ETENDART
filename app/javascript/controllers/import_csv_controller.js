import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="import-csv"
export default class extends Controller {
  static targets = ["csvFileInput", "importButton", "spinner"]
  connect() {
    console.log("Hello")
  }

  handleFileSelect(event) {
    if (this.csvFileInputTarget.value) {
      this.importButtonTarget.disabled = false
    } else {
      this.importButtonTarget.disabled = true
    }
  }

  showSpinner() {
    console.log("showSpinner");
    this.spinnerTarget.classList.remove("d-none")
  }
}
