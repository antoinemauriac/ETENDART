import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="import-csv"
export default class extends Controller {
  static targets = ["csvFileInput", "importButton"]
  connect() {
    console.log("Import CSV controller connected")
  }

  handleFileSelect(event) {
    if (this.csvFileInputTarget.value) {
      this.importButtonTarget.disabled = false
    } else {
      this.importButtonTarget.disabled = true
    }
  }
}
