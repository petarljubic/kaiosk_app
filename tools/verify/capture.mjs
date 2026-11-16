import { mkdirSync } from "node:fs";

const slug = process.argv[2] || "unspecified";
const url = process.env.APP_BASE_URL;
const destination = `.ai/evidence/${slug}`;
mkdirSync(destination, { recursive: true });

if (!url) {
  console.error("APP_BASE_URL is not set. Visual check is unverified.");
  process.exit(2);
}

let chromium;
try {
  ({ chromium } = await import("playwright"));
} catch {
  console.error("Playwright is not installed. Visual check is unverified.");
  process.exit(2);
}

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto(url);
const path = `${destination}/page.png`;
await page.screenshot({ path });
await browser.close();
console.log(path);
