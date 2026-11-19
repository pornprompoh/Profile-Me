import profile from "./data/myProfile.js";
import { renderNavbar } from "./modules/navbar.js";
import { renderHero } from "./modules/hero.js";
import { renderAbout } from "./modules/about.js";
import { renderProjects } from "./modules/projects.js";
import { renderContact } from "./modules/contact.js";

document.title = profile.site?.title || "";
document.documentElement.lang = profile.site?.language || "th";
const description = document.querySelector("#page-description");
if (description) {
  description.content = profile.site?.description || "";
}

const skipLink = document.querySelector("[data-skip-link]");
if (skipLink) {
  skipLink.textContent = profile.site?.skipToContent || "";
}

renderNavbar(profile);
renderHero(profile);
renderAbout(profile);
renderProjects(profile);
renderContact(profile);
