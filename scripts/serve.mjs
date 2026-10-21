import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import { extname, join, normalize, resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const landingDir = join(root, "dist");
const appDir = join(root, "app", "build", "web");
const port = Number(process.env.PORT_SERVE || 8080);

const types = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".wasm": "application/wasm",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".bin": "application/octet-stream",
  ".frag": "text/plain",
};

async function fileIn(dir, relative) {
  const target = normalize(join(dir, relative));
  if (!target.startsWith(dir)) return null;
  try {
    const info = await stat(target);
    if (info.isFile()) return target;
    if (info.isDirectory()) {
      const index = join(target, "index.html");
      if ((await stat(index)).isFile()) return index;
    }
  } catch {
    return null;
  }
  return null;
}

createServer(async (req, res) => {
  const path = decodeURIComponent(new URL(req.url, "http://localhost").pathname);
  const isApp = path === "/app" || path.startsWith("/app/");
  const dir = isApp ? appDir : landingDir;
  const relative = isApp ? path.slice("/app".length) : path;

  const file = (await fileIn(dir, relative)) ?? join(dir, "index.html");
  try {
    const body = await readFile(file);
    res.writeHead(200, { "Content-Type": types[extname(file)] ?? "application/octet-stream" });
    res.end(body);
  } catch {
    res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    res.end(`Not built yet. Run "npm run build:all" first.`);
  }
}).listen(port, () => {
  console.log(`Landing page: http://localhost:${port}/`);
  console.log(`Web app:      http://localhost:${port}/app/`);
});
