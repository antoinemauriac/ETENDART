import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="enrollment-form"
export default class extends Controller {
  static targets = ["academy", "schoolPeriod", "camp", "activity"];

  connect() {
    console.log("EnrollmentFormController connected");
    this.updateSchoolPeriods();
  }

  updateSchoolPeriods() {
    console.log("Updating school periods");
    console.log(this.schoolPeriodTarget);
    const academyId = this.academyTarget.value;
    console.log(academyId);
    const schoolPeriods = JSON.parse(this.academyTarget.getAttribute("data-school-periods"));
    console.log(schoolPeriods);
    const filteredSchoolPeriods = schoolPeriods.filter(schoolPeriod => schoolPeriod.academy_id == academyId);
    const options = filteredSchoolPeriods.map(schoolPeriod => `<option value="${schoolPeriod.id}">${schoolPeriod.name}</option>`);

    this.schoolPeriodTarget.innerHTML = options.join("");
    this.updateCamps();
  }

  updateCamps() {
    console.log("Updating camps");
    const schoolPeriodId = this.schoolPeriodTarget.value;
    const camps = JSON.parse(this.schoolPeriodTarget.getAttribute("data-camps"));

    const filteredCamps = camps.filter(camp => camp.school_period_id == schoolPeriodId);
    const options = filteredCamps.map(camp => `<option value="${camp.id}">${camp.name}</option>`);

    this.campTarget.innerHTML = options.join("");
    this.updateActivities();
  }

  updateActivities() {
    console.log("Updating activities");
    const campId = this.campTarget.value;
    const activities = JSON.parse(this.campTarget.getAttribute("data-activities"));

    const filteredActivities = activities.filter(activity => activity.camp_id == campId);
    const options = filteredActivities.map(activity => `<option value="${activity.id}">${activity.name}</option>`);

    this.activityTarget.innerHTML = options.join("");
  }
}
