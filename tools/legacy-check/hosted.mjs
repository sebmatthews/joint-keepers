// Hosted check: after the legacy app is deployed to Azure App Service, prove that
// it loads (so the SQLite library works there) and that it can write to its database.
import { chromium } from 'playwright-core';
import { mkdirSync } from 'node:fs';
import { join } from 'node:path';

const base = process.env.HOSTED_URL;
const out = process.env.SCREENS_DIR || 'hosted-screens';
const run = String(process.env.GITHUB_RUN_NUMBER || '1');
const tag = 'LV8' + run.padStart(7, '0');
if (!base) { console.error('HOSTED_URL must be set'); process.exit(2); }
mkdirSync(out, { recursive: true });

const failures = [];
const expect = (ok, what) => { console.log(`${ok ? 'PASS' : 'FAIL'}  ${what}`); if (!ok) failures.push(what); };
const submit = (page, selector) => Promise.all([page.waitForNavigation({ waitUntil: 'load', timeout: 60000 }), page.click(selector)]);

const browser = await chromium.launch(process.env.CHROME_PATH
  ? { executablePath: process.env.CHROME_PATH, headless: true }
  : { channel: 'chrome', headless: true });
const page = await browser.newPage({ viewport: { width: 1024, height: 700 } });

try {
  // The free tier may take a while to wake the app after a deploy.
  const started = Date.now();
  let ready = false;
  while (!ready && Date.now() - started < 240000) {
    try {
      const r = await page.goto(base, { waitUntil: 'load', timeout: 60000 });
      ready = r && r.status() === 200 && (await page.locator('h1').count()) > 0;
    } catch { /* not up yet */ }
    if (!ready) await new Promise((r) => setTimeout(r, 5000));
  }
  console.log(`First good response after ${Math.round((Date.now() - started) / 1000)} seconds`);
  expect(ready, 'hosted app answers with the holdings page');

  const rows = await page.locator('table.grid tr').count();
  expect(rows - 1 === 6, `holdings list shows 6 holdings, so SQLite loads (got ${rows - 1})`);
  await page.screenshot({ path: join(out, 'hosted-01-holdings.png'), fullPage: true });

  const row = page.locator('table.grid tr', { hasText: 'DM/103/0003' });
  await Promise.all([page.waitForNavigation({ waitUntil: 'load' }), row.locator('a').first().click()]);
  const holdingUrl = page.url();
  await page.fill('#txtTag', tag);
  await page.selectOption('#ddlSpecies', { label: 'Cattle' });
  await page.fill('#txtDob', '14/03/2024');
  await page.selectOption('#ddlKeeper', { label: 'Priya Oakley' });
  await submit(page, '#btnRegister');
  const message = (await page.locator('#lblMessage').textContent())?.trim();
  expect(message === `Animal ${tag} registered`, `registering ${tag} reports success (got '${message}')`);
  await page.screenshot({ path: join(out, 'hosted-02-registered.png'), fullPage: true });

  await page.goto(holdingUrl, { waitUntil: 'load' });
  const kept = await page.locator('table.grid tr', { hasText: tag }).count();
  expect(kept === 1, `${tag} is still there after reloading the page, so the database was written`);
  await page.screenshot({ path: join(out, 'hosted-03-reloaded.png'), fullPage: true });
} catch (err) {
  expect(false, `hosted check ran without error: ${err.message.split('\n')[0]}`);
  await page.screenshot({ path: join(out, 'hosted-99-error.png'), fullPage: true }).catch(() => {});
} finally {
  await browser.close();
}

if (failures.length) { console.error(`${failures.length} hosted check(s) failed`); process.exit(1); }
console.log('Hosted checks passed');
