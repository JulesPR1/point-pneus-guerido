import { Controller } from "@hotwired/stimulus"

// Drag & drop reordering with the native HTML5 drag events — no library.
// The up/down buttons remain the accessible, JavaScript-free path.
export default class extends Controller {
  static targets = ["item"]
  static values = { url: String }

  connect() {
    this.itemTargets.forEach((item) => {
      item.addEventListener("dragstart", this.onDragStart)
      item.addEventListener("dragover", this.onDragOver)
      item.addEventListener("dragleave", this.onDragLeave)
      item.addEventListener("drop", this.onDrop)
      item.addEventListener("dragend", this.onDragEnd)
    })
  }

  onDragStart = (event) => {
    this.dragged = event.currentTarget
    this.dragged.classList.add("is-dragging")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.dragged.dataset.id)
  }

  onDragOver = (event) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    if (event.currentTarget !== this.dragged) event.currentTarget.classList.add("is-over")
  }

  onDragLeave = (event) => {
    event.currentTarget.classList.remove("is-over")
  }

  onDrop = (event) => {
    event.preventDefault()
    const target = event.currentTarget
    target.classList.remove("is-over")
    if (!this.dragged || target === this.dragged) return

    const items = [...this.element.children]
    const isAfter = items.indexOf(this.dragged) < items.indexOf(target)
    target.insertAdjacentElement(isAfter ? "afterend" : "beforebegin", this.dragged)
    this.persist()
  }

  onDragEnd = () => {
    this.dragged?.classList.remove("is-dragging")
    this.dragged = null
  }

  persist() {
    const body = new FormData()
    this.itemTargets.forEach((item) => body.append("ordered_ids[]", item.dataset.id))

    fetch(this.urlValue, {
      method: "PATCH",
      body,
      headers: { "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content },
      credentials: "same-origin"
    }).then((response) => {
      if (!response.ok) window.location.reload()
    })
  }
}
