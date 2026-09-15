import { Controller } from "@hotwired/stimulus"

// Search and select inside the icon library. The markup is already on the page:
// this only hides what does not match and keeps the hidden input in sync.
export default class extends Controller {
  static targets = ["input", "preview", "name", "search", "option", "family", "empty"]

  connect() {
    this.terms = this.optionTargets.map((option) => fold(option.dataset.terms))
    this.scrollToSelected()
  }

  filter() {
    const query = fold(this.searchTarget.value).trim()
    let matches = 0

    this.optionTargets.forEach((option, index) => {
      const hit = query === "" || this.terms[index].includes(query)
      option.hidden = !hit
      if (hit) matches += 1
    })

    // A family with nothing left in it would just leave a dangling heading.
    this.familyTargets.forEach((family) => {
      family.hidden = !family.querySelector(".icon-option:not([hidden])")
    })

    this.emptyTarget.hidden = matches > 0
  }

  choose(event) {
    const option = event.currentTarget
    const chosen = option.dataset.name

    this.inputTarget.value = chosen
    this.optionTargets.forEach((other) => {
      const selected = other === option
      other.classList.toggle("is-selected", selected)
      other.setAttribute("aria-pressed", String(selected))
    })

    this.previewTarget.innerHTML = option.querySelector("svg").outerHTML
    this.nameTarget.textContent = option.title
  }

  clear() {
    this.inputTarget.value = ""
    this.optionTargets.forEach((option) => {
      option.classList.remove("is-selected")
      option.setAttribute("aria-pressed", "false")
    })
    this.nameTarget.textContent = "Déduite du titre"
    this.searchTarget.value = ""
    this.filter()
  }

  // Centre the current icon in its own box — never by scrolling the page.
  scrollToSelected() {
    const selected = this.element.querySelector(".icon-option.is-selected")
    const box = this.element.querySelector(".icon-picker__scroll")
    if (!selected || !box) return

    box.scrollTop = selected.offsetTop - box.clientHeight / 2 + selected.clientHeight / 2
  }
}

// "Géométrie" and "geometrie" have to find the same icon.
function fold(text) {
  return (text || "").normalize("NFD").replace(/\p{Mn}/gu, "").toLowerCase()
}
