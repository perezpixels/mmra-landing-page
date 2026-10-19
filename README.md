# MMRA

Ghana legal research SaaS — **landing page** now; **portal / dashboard** next (Laravel + Blade). Connects statutes, cases, courts, judges, and study paths in one workspace for students and practitioners.

| Surface | Path |
| --- | --- |
| Landing (this repo) | React + Vite + Tailwind in [`src/`](src/) |
| Live preview | GitHub Pages → `/mmra-landing-page/` |
| Portal / dashboard (planned) | Laravel + Blade — separate webapp, not in this repo yet |

## Preview

After GitHub Pages deploys:

- **Landing:** https://perezpixels.github.io/mmra-landing-page/

## Local run

```bash
npm ci
npm run dev
```

Open http://localhost:8443 — sections cover Library, Study, Courts & Judges, Ask MMRA, Pricing, and waitlist CTA. Design is Figma Make–sourced; do not change layout or copy unless asked.

Production build:

```bash
npm run build
npm run preview
```

## Stack

- React 19 + TypeScript
- Vite 8
- Tailwind CSS v4
- lucide-react icons

## Deploy

Push to `main` runs [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml) and publishes `dist/` to GitHub Pages.

## Repo

https://github.com/perezpixels/mmra-landing-page
