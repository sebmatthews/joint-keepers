// Phase 1 check for the legacy app. Uses the Chrome already installed on the machine,
// so no browser download is needed. Exits non-zero if any expectation fails.
import { chromium } from 'playwright-core';
import { mkdirSync } from 'node:fs';
import { join } from 'node:path';

const base = process.env.LEGACY_URL || 'http://localhost:8080/';
const out = process.env.SCREENS_DIR || 'screens';
mkdirSync(out, { recursive: true });

const failures = [];
const expect = (ok, what) => {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${what}`);
  if (!ok) failures.push(what);
};

// CHROME_PATH lets the check run somewhere Chrome is not installed as a channel.
const browser = await chromium.launch(process.env.CHROME_PATH
  ? { executablePath: process.env.CHROME_PATH, headless: true }
  : { channel: 'chrome', headless: true });
const page = await browser.newPage({ viewport: { width: 1024, height: 700 } });

try {
  const response = await page.goto(base, { waitUntil: 'load' });
  expect(response && response.status() === 200, `home page returns 200 (got ${response && response.status()})`);
  expect((await page.locator('h1').textContent())?.trim() === 'Register livestock', 'heading reads Register livestock');

  const rows = await page.locator('table.grid tr').count();
  expect(rows - 1 === 6, `holdings list shows 6 holdings (got ${rows - 1})`);
  await page.screenshot({ path: join(out, '01-holdings.png'), fullPage: true });

  await page.fill('#txtSearch', 'Muddlecombe');
  await Promise.all([page.waitForNavigation({ waitUntil: 'load' }), page.click('#btnSearch')]);
  const found = await page.locator('table.grid tr').count();
  expect(found - 1 === 2, `searching Muddlecombe shows 2 holdings (got ${found - 1})`);
  await page.screenshot({ path: join(out, '02-holdings-search.png'), fullPage: true });
} catch (err) {
  expect(false, `check ran without error: ${err.message}`);
  await page.screenshot({ path: join(out, '99-error.png'), fullPage: true }).catch(() => {});
} finally {
  await browser.close();
}

if (failures.length) {
  console.error(`${failures.length} check(s) failed`);
  process.exit(1);
}
console.log('All checks passed');
