import { Controller } from "@hotwired/stimulus"

// Flash messages that show up, wait, and go away. Everything visual lives in
// CSS: this only flips classes and holds the timers, so a toast still reads
// fine if the stylesheet's motion is turned off by prefers-reduced-motion.
const LIFETIME = 6000
const SWIPE_TO_DISMISS = 60 // px

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.timers = new Map()

    this.itemTargets.forEach((toast, index) => {
      // Stagger, so two messages read as a stack rather than as one block.
      setTimeout(() => toast.classList.add("is-visible"), 40 + index * 90)
      this.arm(toast, LIFETIME + index * 400)
      this.watch(toast)
    })
  }

  disconnect() {
    this.timers.forEach((timer) => clearTimeout(timer))
    this.timers.clear()
  }

  dismiss(event) {
    this.leave(event.currentTarget.closest(".toast"))
  }

  // ---- internals -------------------------------------------------

  arm(toast, delay) {
    this.timers.set(toast, setTimeout(() => this.leave(toast), delay))
  }

  disarm(toast) {
    clearTimeout(this.timers.get(toast))
    this.timers.delete(toast)
  }

  // Reading a message should never be interrupted by its own timer.
  watch(toast) {
    const hold = () => this.disarm(toast)
    const release = () => { if (!this.timers.has(toast)) this.arm(toast, 2400) }

    toast.addEventListener("pointerenter", hold)
    toast.addEventListener("pointerleave", release)
    toast.addEventListener("focusin", hold)
    toast.addEventListener("focusout", release)
    this.swipeable(toast, hold)
  }

  // Sideways flick to get rid of a toast, the way a notification behaves.
  swipeable(toast, hold) {
    let start = null

    toast.addEventListener("pointerdown", (event) => {
      // Capturing the pointer would steal the click from the close button.
      if (event.button !== 0 || event.target.closest(".toast__close")) return
      start = event.clientX
      hold()
      toast.setPointerCapture(event.pointerId)
      toast.classList.add("is-dragging")
    })

    toast.addEventListener("pointermove", (event) => {
      if (start === null) return
      toast.style.setProperty("--toast-drag", `${Math.max(0, event.clientX - start)}px`)
    })

    const end = (event) => {
      if (start === null) return
      const travelled = event.clientX - start
      start = null
      toast.classList.remove("is-dragging")
      toast.style.removeProperty("--toast-drag")

      if (travelled > SWIPE_TO_DISMISS) this.leave(toast)
      else this.arm(toast, 2400)
    }

    toast.addEventListener("pointerup", end)
    toast.addEventListener("pointercancel", end)
  }

  leave(toast) {
    if (!toast || toast.classList.contains("is-leaving")) return

    this.disarm(toast)
    toast.classList.add("is-leaving")
    toast.addEventListener("transitionend", () => toast.remove(), { once: true })
    // A toast must not survive a stylesheet that never transitions.
    setTimeout(() => toast.remove(), 500)
  }
}
