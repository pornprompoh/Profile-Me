import { createElement } from "../utils/domUtils.js";

export function renderNavbar(profile) {
  const header = document.querySelector("[data-navbar]");
  if (!header) {
    return;
  }

  const navigation = profile.navigation || {};
  const brand = createElement("a", "navbar-brand", profile.identity?.nickname);
  brand.href = "#home";
  brand.setAttribute("aria-label", navigation.home || "");

  const toggle = createElement("button", "menu-toggle");
  toggle.type = "button";
  toggle.setAttribute("aria-expanded", "false");
  toggle.setAttribute("aria-label", navigation.openMenu || "");
  toggle.setAttribute("aria-controls", "primary-navigation");
  toggle.append(createElement("span", "menu-toggle-line"), createElement("span", "menu-toggle-line"));

  const nav = createElement("nav", "primary-navigation");
  nav.id = "primary-navigation";
  nav.setAttribute("aria-label", navigation.home || "");
  [
    ["home", "home"],
    ["about", "about"],
    ["projects", "projects"],
    ["contact", "contact"]
  ].forEach(([section, labelKey]) => {
    const link = createElement("a", "nav-link", navigation[labelKey]);
    link.href = `#${section}`;
    nav.append(link);
  });

  toggle.addEventListener("click", () => {
    const isOpen = toggle.getAttribute("aria-expanded") === "true";
    toggle.setAttribute("aria-expanded", String(!isOpen));
    toggle.setAttribute("aria-label", isOpen ? navigation.openMenu || "" : navigation.closeMenu || "");
    nav.classList.toggle("is-open", !isOpen);
  });

  nav.addEventListener("click", (event) => {
    if (event.target instanceof HTMLAnchorElement) {
      nav.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
      toggle.setAttribute("aria-label", navigation.openMenu || "");
    }
  });

  header.replaceChildren(createElement("div", "navbar-inner"));
  const inner = header.firstElementChild;
  inner.append(brand, toggle, nav);
}
