import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feedback-form"
export default class extends Controller {

  static targets = [ "feedbackModal" ]

  connect() {
  }

  openFeedbackModal() {
    this.feedbackModalTarget.classList.add('show');
    this.feedbackModalTarget.style.display = 'block';
    this.feedbackModalTarget.removeAttribute('aria-hidden');
    document.body.classList.add('modal-open');
    this.feedbackModalTarget.addEventListener('click', this.handleModalClick.bind(this));
    window.addEventListener('click', this.handleWindowClick.bind(this));
  }

  closeFeedbackModal() {
    this.feedbackModalTarget.classList.remove('show');
    this.feedbackModalTarget.style.display = 'none';
    this.feedbackModalTarget.setAttribute('aria-hidden', true);
    document.body.classList.remove('modal-open');
    this.feedbackModalTarget.removeEventListener('click', this.handleModalClick.bind(this));
    window.removeEventListener('click', this.handleWindowClick.bind(this));
  }

  handleModalClick(event) {
    if (event.target.getAttribute('data-dismiss') === 'modal') {
      this.closeFeedbackModal();
    }
  }

  handleWindowClick(event) {
    if (event.target === this.feedbackModalTarget) {
      this.closeFeedbackModal();
    }
  }
}
