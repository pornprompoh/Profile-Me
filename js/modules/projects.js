import { createElement, createExternalLink, setOptionalImage } from "../utils/domUtils.js";

function openLightbox(source, alt, label) {
  if (!source) {
    return;
  }

  const dialog = createElement("dialog", "m3-lightbox");
  dialog.setAttribute("aria-label", label || alt || "");
  const closeButton = createElement("button", "m3-button m3-button-tonal lightbox-close", label);
  closeButton.type = "button";
  closeButton.addEventListener("click", () => dialog.close());
  const image = createElement("img", "lightbox-image");
  image.src = source;
  image.alt = alt || "";
  image.addEventListener("error", () => dialog.close(), { once: true });
  dialog.append(closeButton, image);
  dialog.addEventListener("click", (event) => {
    if (event.target === dialog) {
      dialog.close();
    }
  });
  dialog.addEventListener("close", () => dialog.remove(), { once: true });
  document.body.append(dialog);
  dialog.showModal();
}

export function renderProjects(profile) {
  const section = document.querySelector("[data-projects]");
  if (!section) {
    return;
  }

  const projects = profile.projects || {};
  const items = Array.isArray(projects.items) ? projects.items : [];
  const content = createElement("div", "projects-content");
  content.append(
    createElement("p", "eyebrow", projects.eyebrow),
    createElement("h2", "section-title", projects.heading),
    createElement("p", "section-introduction", projects.introduction)
  );
  content.querySelector(".section-title").id = "projects-title";

  const categories = [...new Set(items.map((item) => item.category).filter(Boolean))];
  const filters = createElement("div", "project-filters");
  const allFilter = createElement("button", "m3-chip is-selected", projects.allCategoriesLabel);
  allFilter.type = "button";
  allFilter.setAttribute("aria-pressed", "true");
  allFilter.dataset.category = "";
  filters.append(allFilter);

  categories.forEach((category) => {
    const filter = createElement("button", "m3-chip", category);
    filter.type = "button";
    filter.setAttribute("aria-pressed", "false");
    filter.dataset.category = category;
    filters.append(filter);
  });

  const grid = createElement("div", "project-grid");
  const emptyState = createElement("p", "project-empty", projects.emptyLabel);
  emptyState.hidden = items.length > 0;

  items.forEach((project) => {
    const card = createElement("article", "m3-card project-card");
    const imageFrame = createElement("div", "project-image-frame");
    const image = setOptionalImage(
      imageFrame,
      project.image,
      project.title ? `${projects.imageOpenLabel}: ${project.title}` : projects.imageOpenLabel,
      "project-image"
    );
    if (project.image) {
      imageFrame.classList.add("is-zoomable");
      imageFrame.setAttribute("role", "button");
      imageFrame.setAttribute("tabindex", "0");
      imageFrame.setAttribute("aria-label", project.title ? `${projects.imageOpenLabel}: ${project.title}` : projects.imageOpenLabel || "");
      imageFrame.addEventListener("click", () => openLightbox(project.image, project.title, profile.modal?.closeLabel));
      imageFrame.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          openLightbox(project.image, project.title, profile.modal?.closeLabel);
        }
      });
    }

    const cardContent = createElement("div", "project-card-content");
    if (project.category) {
      cardContent.append(createElement("span", "m3-chip project-category", project.category));
    }
    cardContent.append(
      createElement("h3", "project-title", project.title),
      createElement("p", "project-description", project.description)
    );
    const githubLink = createExternalLink(project.githubUrl, projects.githubLabel, "m3-button m3-button-outlined");
    if (githubLink) {
      cardContent.append(githubLink);
    }

    card.append(imageFrame, cardContent);
    if (project.category) {
      card.dataset.category = project.category;
    }
    grid.append(card);
  });

  filters.addEventListener("click", (event) => {
    const filter = event.target.closest("button[data-category]");
    if (!filter) {
      return;
    }

    filters.querySelectorAll("button[data-category]").forEach((button) => {
      const selected = button === filter;
      button.classList.toggle("is-selected", selected);
      button.setAttribute("aria-pressed", String(selected));
    });

    let visibleCount = 0;
    grid.querySelectorAll(".project-card").forEach((card) => {
      const visible = !filter.dataset.category || card.dataset.category === filter.dataset.category;
      card.hidden = !visible;
      if (visible) {
        visibleCount += 1;
      }
    });
    emptyState.hidden = visibleCount > 0;
  });

  content.append(filters, grid, emptyState);
  section.replaceChildren(content);
}
