// GitHub Pages serves the site under /<repo-name>/; locally BASE_URL is "/".
export const basename = import.meta.env.BASE_URL.replace(/\/$/, "");

export function withBase(path: string) {
  return `${basename}${path}`;
}
