import { Controller } from "@hotwired/stimulus"
// Connects to data-controller="loading-message"
export default class extends Controller {
  static targets = [ "turboFrame" ];
  timeoutId = null;

  connect() {
    this.turboFrameTarget.addEventListener("turbo:frame-load", () => this.hideLoading());
  }

  showLoading() {
    const turboFrame = this.turboFrameTarget;

    // Délai avant d'afficher le loader (1 seconde ici)
    this.timeoutId = setTimeout(() => {
      if (turboFrame) {
        turboFrame.innerHTML = `
          <div class="flexy" style="height: 20vh;">
            <div class="small-loader"></div>
          </div>
        `;
      }
    }, 500);
  }

  hideLoading() {
    // Annuler le timeout si le chargement est terminé avant 1 seconde
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
}
