import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading-message"
export default class extends Controller {
  static targets = [ "turboFrame" ]

  showLoading() {
    const turboFrame = this.turboFrameTarget;
    if (turboFrame) {
      turboFrame.innerHTML = `
        <div class="flexy" style="height: 20vh;">
          <div class="small-loader"></div>
        </div>
      `;
    }
  }
}
