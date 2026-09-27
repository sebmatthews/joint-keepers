// Golden master runner.
//   record:  run every scenario against an app and save what happened to golden/results.
//   compare: run every scenario and check the outcome matches the saved golden results exactly.
//
// Settings, from the environment:
//   APP_URL       where the app is running, for example http://localhost:8080/
//   APP_DB        the database file the running app uses; reset from the pristine copy before each scenario
//   PRISTINE_DB   the pristine database (default: db/livestock.db)
//   DRIVER        which app's driver to use: legacy (default) or modern
//   MODE          record (default) or compare
//   RESULTS_DIR   where results are written or read (default: golden/results)
//   SCREENS_DIR   where screenshots go (default: build/screens)
//   CHROME_PATH   optional path to a Chrome or Chromium; otherwise the installed Chrome is used
import { chromium } from 'playwright-core';
import { DatabaseSync } from 'node:sqlite';
import { readFileSync, writeFileSync, mkdirSync, copyFileSync, existsSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { isDeepStrictEqual } from 'node:util';

const here = dirname(fileURLToPath(import.meta.url));
const repo = resolve(here, '..');
const APP_URL = process.env.APP_URL || 'http://localhost:8080/';
const APP_DB = process.env.APP_DB;
const PRISTINE_DB = process.env.PRISTINE_DB || join(repo, 'db', 'livestock.db');
const DRIVER = process.env.DRIVER || 'legacy';
const MODE = process.env.MODE || 'record';
const RESULTS_DIR = process.env.RESULTS_DIR || join(here, 'results');
const SCREENS_DIR = process.env.SCREENS_DIR || join(repo, 'build', 'screens');

if (!APP_DB) { console.error('APP_DB must be set to the database file the running app uses'); process.exit(2); }
mkdirSync(RESULTS_DIR, { recursive: true });
mkdirSync(SCREENS_DIR, { recursive: true });

const { scenarios } = JSON.parse(readFileSync(join(here, 'scenarios.json'), 'utf8'));
const { [`${DRIVER}Driver`]: makeDriver } = await import(`./drivers/${DRIVER}.mjs`);

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
async function resetDatabase() {
  for (let attempt = 1; ; attempt++) {
    try { copyFileSync(PRISTINE_DB, APP_DB); return; }
    catch (err) { if (attempt >= 10) throw err; await sleep(500); }
  }
}

function dumpDatabase() {
  const db = new DatabaseSync(APP_DB, { readOnly: true });
  const tables = db.prepare("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name").all().map((r) => r.name);
  const dump = {};
  for (const t of tables) dump[t] = db.prepare(`SELECT * FROM "${t}" ORDER BY 1`).all().map((r) => ({ ...r }));
  db.close();
  return dump;
}

const browser = await chromium.launch(process.env.CHROME_PATH
  ? { executablePath: process.env.CHROME_PATH, headless: true }
  : { channel: 'chrome', headless: true });

let failed = 0;
for (const s of scenarios) {
  await resetDatabase();
  const page = await browser.newPage({ viewport: { width: 1024, height: 700 } });
  const driver = makeDriver(page, APP_URL);
  let outcome;
  try {
    for (const step of s.steps) {
      const { do: action, screenshot, ...args } = step;
      if (!driver[action]) throw new Error(`The ${DRIVER} driver has no step called ${action}`);
      await driver[action](args);
      if (screenshot) await page.screenshot({ path: join(SCREENS_DIR, `${screenshot}.png`), fullPage: true });
    }
    outcome = { scenario: s.id, title: s.title, screen: await driver.readScreen(), database: dumpDatabase() };
  } catch (err) {
    outcome = { scenario: s.id, title: s.title, error: err.message.split('\n')[0] };
    await page.screenshot({ path: join(SCREENS_DIR, `error-${s.id}.png`), fullPage: true }).catch(() => {});
  }
  await page.close();

  const file = join(RESULTS_DIR, `${s.id}.json`);
  if (MODE === 'record') {
    writeFileSync(file, JSON.stringify(outcome, null, 2) + '\n');
    const ok = !outcome.error;
    if (!ok) failed++;
    console.log(`${ok ? 'RECORDED' : 'ERROR   '}  ${s.id}  ${s.title}${ok ? '' : `: ${outcome.error}`}`);
  } else {
    const golden = existsSync(file) ? JSON.parse(readFileSync(file, 'utf8')) : null;
    const ok = golden && !outcome.error && isDeepStrictEqual(outcome.screen, golden.screen) && isDeepStrictEqual(outcome.database, golden.database);
    if (!ok) {
      failed++;
      writeFileSync(join(SCREENS_DIR, `mismatch-${s.id}.json`), JSON.stringify(outcome, null, 2) + '\n');
    }
    console.log(`${ok ? 'PASS' : 'FAIL'}  ${s.id}  ${s.title}${outcome.error ? `: ${outcome.error}` : ''}`);
  }
}
await browser.close();

console.log(failed ? `${failed} scenario(s) did not pass` : `All ${scenarios.length} scenarios ${MODE === 'record' ? 'recorded' : 'match the golden results'}`);
process.exit(failed ? 1 : 0);
