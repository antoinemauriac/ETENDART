import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startTime", "endTime", "mondayStartTime", "mondayEndTime"]

  connect() {
    console.log("hello ");
    this.mondayStartTimeTarget.value = "10:00";
    this.mondayEndTimeTarget.value = "12:00";
    this.startTimeTargets.forEach((input) => (input.value = "10:00"));
    this.endTimeTargets.forEach((input) => (input.value = "12:00"));
  }

  onMondayStartTimeInputChange(event) {
    console.log("onMondayStartTimeInputChange");
    const mondayStartTime = this.mondayStartTimeTarget.value;
    this.startTimeTargets.forEach((input) => (input.value = mondayStartTime))
  }

  onMondayEndTimeInputChange(event) {
    const mondayEndTime = this.mondayEndTimeTarget.value

    this.endTimeTargets.forEach((input) => (input.value = mondayEndTime))
  }
}
