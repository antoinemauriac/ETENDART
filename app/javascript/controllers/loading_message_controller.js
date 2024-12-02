// import { Controller } from "@hotwired/stimulus";

// // Connects to data-controller="loading-message"
// export default class extends Controller {
//   static targets = ["turboFrame"];

//   connect() {
//     // S'assurer que l'effet disparaît après le chargement
//     this.turboFrameTarget.addEventListener("turbo:frame-load", () => this.hideBlur());
//   }

//   showLoading() {
//     const turboFrame = this.turboFrameTarget;

//     if (turboFrame) {
//       // Ajouter la classe CSS pour l'effet blur
//       turboFrame.classList.add("blur-effect");
//     }
//   }

//   hideBlur() {
//     const turboFrame = this.turboFrameTarget;

//     if (turboFrame) {
//       // Supprimer la classe CSS une fois chargé
//       turboFrame.classList.remove("blur-effect");
//     }
//   }
// }
