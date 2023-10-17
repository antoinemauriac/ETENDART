import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="coach-courses"
export default class extends Controller {

  static targets = [ "future", "past", "futureCourses", "pastCourses" ]

  connect() {
    console.log("Hello, Stimulus!")
  }

  showPast() {
    this.futureCoursesTarget.classList.add("d-none")
    this.pastCoursesTarget.classList.remove("d-none")
    this.futureTarget.classList.remove("active")
    this.pastTarget.classList.add("active")
  }

  showFuture() {
    this.futureCoursesTarget.classList.remove("d-none")
    this.pastCoursesTarget.classList.add("d-none")
    this.futureTarget.classList.add("active")
    this.pastTarget.classList.remove("active")
  }
}
