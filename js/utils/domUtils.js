export function createElement(tagName, className, text) {
  const element = document.createElement(tagName);

  if (className) {
    element.className = className;
  }
  if (text !== undefined && text !== null) {
    element.textContent = String(text);
  }

  return element;
}

export function setOptionalImage(container, source, alt, className) {
  if (!container) {
    return null;
  }

  const placeholder = () => {
    const fallback = createElement("div", `${className} image-placeholder`);
    fallback.setAttribute("role", "img");
    fallback.setAttribute("aria-label", alt || "");
    container.replaceChildren(fallback);
    return fallback;
  };

  if (typeof source !== "string" || !source.trim()) {
    return placeholder();
  }

  const image = createElement("img", className);
  image.src = source;
  image.alt = alt || "";
  image.addEventListener("error", placeholder, { once: true });
  container.replaceChildren(image);
  return image;
}

export function createExternalLink(url, label, className) {
  if (typeof url !== "string" || !url.trim()) {
    return null;
  }

  let parsedUrl;
  try {
    parsedUrl = new URL(url, window.location.href);
  } catch {
    return null;
  }

  if (
    parsedUrl.protocol !== "https:" &&
    parsedUrl.protocol !== "mailto:" &&
    parsedUrl.protocol !== "tel:"
  ) {
    return null;
  }

  const link = createElement("a", className, label);
  link.href = parsedUrl.href;
  if (parsedUrl.protocol === "https:") {
    link.target = "_blank";
    link.rel = "noopener noreferrer";
  }
  return link;
}
