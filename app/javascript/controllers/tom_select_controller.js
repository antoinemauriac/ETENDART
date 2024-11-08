import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  connect() {
    if (!this.element._tomSelect) {
      this.element._tomSelect = new TomSelect(this.element, {
        plugins: ['remove_button'],
      });
    }
  }
}
