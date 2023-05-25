import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="enrollment-form"
export default class extends Controller {
  static targets = ["academy", "schoolPeriod", "camp", "activity", "activityModal"];

  connect() {
    console.log("toto");
  }


  openActivityModal() {
    this.activityModalTarget.classList.add('show');
    this.activityModalTarget.style.display = 'block';
    this.activityModalTarget.removeAttribute('aria-hidden');
    document.body.classList.add('modal-open');
    this.activityModalTarget.addEventListener('click', this.handleModalClick.bind(this));
    window.addEventListener('click', this.handleWindowClick.bind(this));
  }

  closeActivityModal() {
    this.activityModalTarget.classList.remove('show');
    this.activityModalTarget.style.display = 'none';
    this.activityModalTarget.setAttribute('aria-hidden', true);
    document.body.classList.remove('modal-open');
    this.activityModalTarget.removeEventListener('click', this.handleModalClick.bind(this));
    window.removeEventListener('click', this.handleWindowClick.bind(this));
  }

  handleModalClick(event) {
    if (event.target.getAttribute('data-dismiss') === 'modal') {
      this.closeActivityModal();
    }
  }

  handleWindowClick(event) {
    if (event.target === this.activityModalTarget) {
      this.closeActivityModal();
    }
  }

  updateSchoolPeriods() {
    const academy_id = this.academyTarget.value
    const url = `/managers/enrollments/${academy_id}/update_school_periods`

    fetch(url)
      .then(response => response.json())
      .then(schoolPeriods => {
        this.schoolPeriodTarget.innerHTML = ''
        this.schoolPeriodTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        schoolPeriods.forEach(schoolPeriod => {
          const option = document.createElement('option')
          option.value = schoolPeriod.id
          option.textContent = `${schoolPeriod.full_name}`
          console.log(option.textContent);
          this.schoolPeriodTarget.appendChild(option)
        })
      })
  }

  updateCamps() {
    const school_period_id = this.schoolPeriodTarget.value
    const url = `/managers/enrollments/${school_period_id}/update_camps`

    fetch(url)
      .then(response => response.json())
      .then(camps => {
        this.campTarget.innerHTML = ''
        this.campTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        camps.forEach(camp => {
          const option = document.createElement('option')
          option.value = camp.id
          option.textContent = `${camp.name}`
          this.campTarget.appendChild(option)
        })
      })
  }

  updateActivities() {
    const camp_id = this.campTarget.value
    const url = `/managers/enrollments/${camp_id}/update_activities`

    fetch(url)
      .then(response => response.json())
      .then(activities => {
        this.activityTarget.innerHTML = ''
        this.activityTarget.insertAdjacentHTML('beforeend', '<option value=""></option>');
        activities.forEach(activity => {
          const option = document.createElement('option')
          option.value = activity.id
          option.textContent = `${activity.name}`
          this.activityTarget.appendChild(option)
        })
      })
  }
}
