import { Controller } from "@hotwired/stimulus"
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder"

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static values = { apiKey: String }

  static targets = ["address"]

  connect() {
    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: "country,region,place,postcode,locality,neighborhood,address",
      countries: 'FR',
      container: "address-container", // ID of the container where you want to render the geocoder control
      placeholder: "12 rue Jean Jaurès...", // Placeholder text for the geocoder control
      className: "form-control",
    })
      this.geocoder.addTo(this.element)

      this.geocoder.on("result", event => this.#setInputValue(event))
      this.geocoder.on("clear", () => this.#clearInputValue())
    }

    #setInputValue(event) {
      this.addressTarget.value = event.result["place_name"]
    }

    #clearInputValue() {
      this.addressTarget.value = ""
  }

  disconnect() {
    this.geocoder.onRemove()
  }
}
