import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="loading-message"
export default class extends Controller {
  static targets = ["turboFrame"];
  timeoutId = null;

  connect() {
    if (this.hasTurboFrameTarget) {
      this.turboFrameTarget.addEventListener("turbo:frame-load", this.hideLoading.bind(this));
    }
  }

  disconnect() {
    if (this.hasTurboFrameTarget) {
      this.turboFrameTarget.removeEventListener("turbo:frame-load", this.hideLoading.bind(this));
    }
  }

  showLoading() {
    if (this.hasTurboFrameTarget) {
      this.timeoutId = setTimeout(() => {
        this.turboFrameTarget.innerHTML = `
          <div class="flexy" style="height: 20vh;">
            <div class="small-loader"></div>
          </div>
        `;
      }, 500);
    }
  }

  hideLoading() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
}
