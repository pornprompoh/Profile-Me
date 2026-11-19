import { createElement, setOptionalImage } from "../utils/domUtils.js";

export function renderHero(profile) {
  const section = document.querySelector("[data-hero]");
  if (!section) {
    return;
  }

  const hero = profile.hero || {};
  const identity = profile.identity || {};
  const content = createElement("div", "hero-content");
  content.append(
    createElement("p", "eyebrow", hero.greeting),
    createElement("h1", "hero-title", identity.fullName),
    createElement("p", "hero-nickname", identity.nickname),
    createElement("p", "hero-role", identity.role),
    createElement("p", "hero-description", hero.introduction)
  );
  content.querySelector(".hero-title").id = "hero-title";

  const actions = createElement("div", "hero-actions");
  const projectsAction = createElement("a", "m3-button m3-button-filled", hero.primaryAction);
  projectsAction.href = "#projects";
  const contactAction = createElement("a", "m3-button m3-button-tonal", hero.secondaryAction);
  contactAction.href = "#contact";
  actions.append(projectsAction, contactAction);
  content.append(actions);

  const visual = createElement("div", "hero-visual");
  const imageFrame = createElement("div", "hero-image-frame");
  setOptionalImage(imageFrame, identity.image, identity.imageAlt, "hero-image");
  visual.append(imageFrame);

  section.replaceChildren(content, visual);
}
