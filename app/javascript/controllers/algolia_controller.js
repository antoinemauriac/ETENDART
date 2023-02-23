import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Hello from Algolia")
    console.log("places", places);

    document.addEventListener("turbolinks:load", function() {
      var placesAutocomplete = places({
        appId: 'WK95B3KERH',
        apiKey: 'ff5a203b722ed22fc011a54466bb4ab7',
        container: document.querySelector('#location-form input[name="address"]')
      });

      console.log("placesAutocomplete", placesAutocomplete);
      placesAutocomplete.on('change', function(e) {
        console.log(e.suggestion);
      });
      placesAutocomplete.on('clear', function() {
        console.log("Input was cleared");
      });
      placesAutocomplete.on('error', function(e) {
        console.log("Error:", e);
      });
    });
  }
}
