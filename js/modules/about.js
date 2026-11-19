import { calculateAge, formatThaiDate, getCurrentBuddhistYear } from "../utils/dateUtils.js";
import { createElement } from "../utils/domUtils.js";

export function renderAbout(profile) {
  const section = document.querySelector("[data-about]");
  if (!section) {
    return;
  }

  const about = profile.about || {};
  const personal = profile.personal || {};
  const today = new Date();
  const age = calculateAge(personal.birthDate, today);
  const details = createElement("dl", "about-details");
  const rows = [
    [about.educationLabel, about.education],
    [about.ageLabel, age === null ? about.ageUnavailable : `${age} ปี`],
    [about.birthDateLabel, formatThaiDate(personal.birthDate) || about.ageUnavailable],
    [about.currentYearLabel, getCurrentBuddhistYear(today) ?? about.ageUnavailable]
  ];

  rows.forEach(([label, value]) => {
    if (!label || value === undefined || value === null || value === "") {
      return;
    }
    details.append(createElement("dt", "", label), createElement("dd", "", value));
  });

  const interests = createElement("ul", "interest-list");
  (Array.isArray(about.interests) ? about.interests : [])
    .filter(Boolean)
    .forEach((interest) => interests.append(createElement("li", "m3-chip", interest)));

  const content = createElement("div", "about-content");
  content.append(
    createElement("p", "eyebrow", about.eyebrow),
    createElement("h2", "section-title", about.heading),
    createElement("p", "section-introduction", about.introduction),
    details
  );
  content.querySelector(".section-title").id = "about-title";

  if (interests.childElementCount) {
    content.append(createElement("h3", "subsection-title", about.interestsLabel), interests);
  }
  section.replaceChildren(content);
}
