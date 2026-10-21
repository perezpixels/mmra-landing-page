# MMRA

Ghana legal research SaaS: **landing page** (React) plus the **web app** (Flutter, ready to ship as a mobile app later). Connects statutes, cases, courts, judges, and study paths in one workspace for students and practitioners.

| Surface | Path |
| --- | --- |
| Landing page | React + Vite + Tailwind in [`src/`](src/) |
| Web app (portal / dashboard) | Flutter in [`app/`](app/), served under `/app/` |
| Web app design reference | Figma Make React source in [`src/webapp/`](src/webapp/) |
| Live preview | GitHub Pages → `/mmra-landing-page/` |

The landing page's **Start free** and **Log in** buttons open the Flutter web app (`/app/onboarding` and `/app/auth?mode=signin`).

## Preview

After GitHub Pages deploys:

- **Landing:** https://perezpixels.github.io/mmra-landing-page/
- **Web app:** https://perezpixels.github.io/mmra-landing-page/app/

## Local run

Needs Node 22 and Flutter 3.44.

```bash
npm ci
npm run build:all   # landing → dist/, Flutter web app → app/build/web/
npm run serve
```

- Landing: http://localhost:8080/
- Web app: http://localhost:8080/app/

Working on one side only:

```bash
npm run dev                 # landing (and React design reference) at http://localhost:8443
cd app && flutter run -d chrome   # Flutter app with hot reload
```

Design is Figma Make–sourced; do not change layout or copy unless asked.

## Stack

- Landing: React 19 + TypeScript, Vite 8, Tailwind CSS v4, lucide-react
- Web app: Flutter 3.44 / Dart 3.12, go_router, google_fonts, lucide_icons_flutter
- Prototype only: no backend; app changes last for the current visit

## Deploy

Push to `main` runs [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml): builds the landing page into `dist/`, builds the Flutter web app into `dist/app/`, and publishes to GitHub Pages.

## Repo

https://github.com/perezpixels/mmra-landing-page
