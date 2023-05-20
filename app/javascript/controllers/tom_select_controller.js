
// import { Controller } from "@hotwired/stimulus"
// import TomSelect from "tom-select";

// export default class extends Controller {
//   connect() {
//     new TomSelect(this.element)
//   }
// }
// loadCoaches() {
//   const category_id = this.categoryTarget.value
//   const academy_id = this.categoryTarget.dataset.academyId
//   // console.log(academy_id);
//   // console.log(category_id);
//   console.log("loadCoaches");
//   const url = `/managers/coaches/${category_id}/category_coaches?academy_id=${academy_id}`

//   fetch(url)
//     .then(response => response.json())
//     .then(coaches => {
//       this.coachTargets.forEach(coachTarget => {
//         coachTarget.innerHTML = ''
//         coachTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
//         coaches.forEach(coach => {
//           const option = document.createElement('option')
//           option.value = coach.id
//           option.textContent = `${coach.first_name} ${coach.last_name}`
//           coachTarget.appendChild(option)
//         })
//         new TomSelect(coachTarget)
//       })
//     })

// }
