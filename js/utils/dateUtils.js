const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

function parseIsoDate(value) {
  if (typeof value !== "string" || !DATE_PATTERN.test(value)) {
    return null;
  }

  const [year, month, day] = value.split("-").map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));

  if (
    date.getUTCFullYear() !== year ||
    date.getUTCMonth() !== month - 1 ||
    date.getUTCDate() !== day
  ) {
    return null;
  }

  return { year, month, day };
}

export function calculateAge(birthDate, today = new Date()) {
  const birth = parseIsoDate(birthDate);
  if (!birth || Number.isNaN(today.getTime())) {
    return null;
  }

  let age = today.getFullYear() - birth.year;
  const birthdayHasPassed =
    today.getMonth() + 1 > birth.month ||
    (today.getMonth() + 1 === birth.month && today.getDate() >= birth.day);

  if (!birthdayHasPassed) {
    age -= 1;
  }

  return age >= 0 ? age : null;
}

export function formatThaiDate(dateValue) {
  const parsed = parseIsoDate(dateValue);
  if (!parsed) {
    return "";
  }

  return new Intl.DateTimeFormat("th-TH-u-ca-buddhist", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC"
  }).format(new Date(Date.UTC(parsed.year, parsed.month - 1, parsed.day)));
}

export function getCurrentBuddhistYear(today = new Date()) {
  if (Number.isNaN(today.getTime())) {
    return null;
  }

  return today.getFullYear() + 543;
}
