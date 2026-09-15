import { Controller } from "@hotwired/stimulus"

// The map iframe is only inserted once the visitor asks for it: no third-party
// request, and no cookie banner, on a page nobody asked to geolocate.
export default class extends Controller {
  static targets = ["placeholder"]
  static values = { src: String }

  load() {
    const frame = document.createElement("iframe")
    frame.src = this.srcValue
    frame.loading = "lazy"
    frame.title = "Plan d'accès au garage"
    // Google's embed is refused without an origin; only the origin travels, never the path.
    frame.referrerPolicy = "strict-origin-when-cross-origin"
    frame.setAttribute("allowfullscreen", "")
    this.element.appendChild(frame)
    this.placeholderTarget.remove()
  }
}
