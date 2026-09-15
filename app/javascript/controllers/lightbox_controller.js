import { Controller } from "@hotwired/stimulus"

// Gallery viewer built on <dialog>: no library, keyboard navigable, and the
// grid still works as plain links when JavaScript is unavailable.
export default class extends Controller {
  static targets = ["dialog", "image", "counter"]

  connect() {
    this.links = Array.from(this.element.querySelectorAll(".gallery a"))
    this.index = 0
  }

  open(event) {
    event.preventDefault()
    this.index = Number(event.params.index ?? 0)
    this.show()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  next() {
    this.index = (this.index + 1) % this.links.length
    this.show()
  }

  previous() {
    this.index = (this.index - 1 + this.links.length) % this.links.length
    this.show()
  }

  show() {
    const link = this.links[this.index]
    this.imageTarget.src = link.getAttribute("href")
    this.imageTarget.alt = link.querySelector("img")?.alt || ""
    this.counterTarget.textContent = `${this.index + 1} / ${this.links.length}`
  }

  keydown(event) {
    if (event.key === "ArrowRight") this.next()
    if (event.key === "ArrowLeft") this.previous()
  }
}
