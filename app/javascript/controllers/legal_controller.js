import { Controller } from "@hotwired/stimulus"

// Mentions légales in a <dialog>: the browser gives us the focus trap, the
// Escape key and the inert background for free. The content is in the page,
// so it stays readable — and indexable — when JavaScript never runs; the
// button then falls back to the plain anchor it already is.
export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    event.preventDefault()
    this.dialogTarget.showModal()
    this.dialogTarget.scrollTop = 0
  }

  close() {
    this.dialogTarget.close()
  }

  // A click on the backdrop lands on the dialog itself, never on its content.
  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.dialogTarget.close()
  }
}
