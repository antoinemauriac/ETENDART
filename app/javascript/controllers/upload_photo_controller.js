// import { Controller } from "@hotwired/stimulus"

// export default class extends Controller {
//   static targets = ["photo", "spinner", "form", "form2"];

//   connect() {
//     const image = this.photoTarget;
//     if (image.complete) {
//       this.spinnerTarget.classList.add("d-none");
//     } else {
//       image.addEventListener("load", () => {
//         this.spinnerTarget.classList.add("d-none");
//         this.formTarget.classList.remove("d-none");
//       });
//     }
//     this.formTarget.addEventListener("change", (event) => {
//       event.preventDefault();
//       this.showSpinner();
//     });
//   }

//   showSpinner() {
//     this.spinnerTarget.classList.remove("d-none");
//     this.photoTarget.classList.add("d-none");
//   }

//   submitForm() {
//     console.log("submitting form");
//     this.form2Target.submit();
//   }
// }
