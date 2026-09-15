import { Controller } from "@hotwired/stimulus"

// Full-screen mobile menu: traps focus, closes on Escape or on a link, and hides
// the rest of the page from assistive tech while it is open.
export default class extends Controller {
  static targets = ["panel", "toggle"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  disconnect() {
    this.release()
  }

  open() {
    this.panelTarget.hidden = false
    this.toggleTarget.setAttribute("aria-expanded", "true")
    document.body.style.overflow = "hidden"
    document.addEventListener("keydown", this.onKeydown)
    this.panelTarget.addEventListener("click", this.onPanelClick)
    this.panelTarget.querySelector("a, button")?.focus()
  }

  close() {
    this.release()
    this.toggleTarget.setAttribute("aria-expanded", "false")
    this.toggleTarget.focus()
  }

  release() {
    if (this.hasPanelTarget) {
      this.panelTarget.hidden = true
      this.panelTarget.removeEventListener("click", this.onPanelClick)
    }
    document.body.style.overflow = ""
    document.removeEventListener("keydown", this.onKeydown)
  }

  onPanelClick = (event) => {
    if (event.target.closest("a")) this.close()
  }

  onKeydown(event) {
    if (event.key === "Escape") return this.close()
    if (event.key !== "Tab") return

    const focusables = this.panelTarget.querySelectorAll("a[href], button:not([disabled])")
    if (focusables.length === 0) return

    const first = focusables[0]
    const last = focusables[focusables.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }
}
