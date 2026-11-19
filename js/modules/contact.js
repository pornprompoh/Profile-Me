import { createElement, createExternalLink } from "../utils/domUtils.js";

export function renderContact(profile) {
  const section = document.querySelector("[data-contact]");
  if (!section) {
    return;
  }

  const contact = profile.contact || {};
  const content = createElement("div", "contact-content");
  content.append(
    createElement("p", "eyebrow", contact.eyebrow),
    createElement("h2", "section-title", contact.heading),
    createElement("p", "section-introduction", contact.introduction)
  );
  content.querySelector(".section-title").id = "contact-title";

  const links = createElement("div", "contact-links");
  const email = createExternalLink(
    contact.email ? `mailto:${contact.email}` : "",
    contact.email ? `${contact.emailLabel}: ${contact.email}` : "",
    "m3-button m3-button-filled"
  );
  const phone = createExternalLink(
    contact.phone ? `tel:${contact.phone.replace(/[^\d+]/g, "")}` : "",
    contact.phone ? `${contact.phoneLabel}: ${contact.phone}` : "",
    "m3-button m3-button-tonal"
  );
  if (email) links.append(email);
  if (phone) links.append(phone);

  (Array.isArray(contact.socialLinks) ? contact.socialLinks : []).forEach((social) => {
    const link = createExternalLink(social.url, social.label, "m3-button m3-button-outlined");
    if (link) links.append(link);
  });

  if (links.childElementCount) {
    content.append(links);
  }

  const footer = document.querySelector("[data-footer]");
  if (footer) {
    footer.replaceChildren(createElement("p", "footer-text", profile.site?.footer));
  }

  section.replaceChildren(content);
}
