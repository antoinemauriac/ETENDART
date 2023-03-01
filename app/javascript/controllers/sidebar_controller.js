import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const arrows = [...document.querySelectorAll(".arrow")];
    arrows.forEach((arrow) => {
      arrow.addEventListener("click", (e) => {
        const arrowParent = e.target.parentElement.parentElement;
        console.log(arrowParent);
        arrowParent.classList.toggle("showMenu");
        const otherParents = arrows.filter((arrow) => arrow !== e.target).map((arrow) => arrow.parentElement.parentElement);
        otherParents.forEach((parent) => {
          parent.classList.remove("showMenu");
        });
      });
    });

    if (window.innerWidth < 800) {
      document.querySelector(".sidebar").classList.add("close");
    };

    const sidebar = document.querySelector(".sidebar");
    const sidebarBtn = document.querySelector(".bx-menu");
    const content = document.querySelector(".content");

    sidebarBtn.addEventListener("click", () => {
      sidebar.classList.toggle("close");

      // Vérifie la largeur de l'écran et la classe de la sidebar
      if (window.innerWidth < 800 && !sidebar.classList.contains("close")) {
        content.style.display = "none";
      } else {
        content.style.display = "block";
      }
    });
  }
}
