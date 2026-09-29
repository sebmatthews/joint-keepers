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
//   SCENARIOS     which scenario file in golden/ to run (default: scenarios.json)
//   COMPARE       in compare mode, what must match: all (default) or screen (after a change to the
//                 database's structure, such as the joint keepers migration, the tables differ by design)
//   EXPECTED_CHANGES  scenario IDs, comma separated, that a deliberate change is expected to alter;
//                 they are reported but do not fail the comparison, unless EXPECTED_DIR is set
//   EXPECTED_DIR  optional folder of approved results for the expected changes: an expected change
//                 must then show exactly the approved screen, or the scenario fails
//   CHROME_PATH   optional path to a Chrome or Chromium; otherwise the installed Chrome is used
//
// Today's date is replaced by '<today>' in everything recorded or compared, because
// records the app dates 'today' would otherwise differ from one day to the next.
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

const SCENARIOS = process.env.SCENARIOS || 'scenarios.json';
const COMPARE = process.env.COMPARE || 'all';
const EXPECTED_CHANGES = (process.env.EXPECTED_CHANGES || '').split(',').map((s) => s.trim()).filter(Boolean);
const EXPECTED_DIR = process.env.EXPECTED_DIR || '';
const { scenarios } = JSON.parse(readFileSync(join(here, SCENARIOS), 'utf8'));

const now = new Date();
const pad = (n) => String(n).padStart(2, '0');
const todayForms = [
  `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`,
  `${pad(now.getDate())}/${pad(now.getMonth() + 1)}/${now.getFullYear()}`,
];
const maskToday = (value) => JSON.parse(JSON.stringify(value, (k, v) =>
  typeof v === 'string' ? todayForms.reduce((s, d) => s.split(d).join('<today>'), v) : v));
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
let changed = 0;
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
    outcome = { scenario: s.id, title: s.title, screen: maskToday(await driver.readScreen()), database: maskToday(dumpDatabase()) };
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
    const same = golden && !outcome.error && isDeepStrictEqual(outcome.screen, golden.screen)
      && (COMPARE === 'screen' || isDeepStrictEqual(outcome.database, golden.database));
    let expected = EXPECTED_CHANGES.includes(s.id);
    // With approved results for the change, the changed screen must match them exactly.
    const approvedFile = EXPECTED_DIR ? join(EXPECTED_DIR, `${s.id}.json`) : '';
    if (!same && expected && !outcome.error && approvedFile && existsSync(approvedFile)) {
      expected = isDeepStrictEqual(outcome.screen, JSON.parse(readFileSync(approvedFile, 'utf8')).screen);
    }
    if (!same) writeFileSync(join(SCREENS_DIR, `mismatch-${s.id}.json`), JSON.stringify(outcome, null, 2) + '\n');
    if (!same && !expected) failed++;
    if (!same && expected && !outcome.error) changed++;
    const verdict = same ? 'PASS' : expected && !outcome.error ? (approvedFile ? 'CHANGED (as approved)' : 'CHANGED (expected)') : 'FAIL';
    if (expected && outcome.error) failed++;
    console.log(`${verdict}  ${s.id}  ${s.title}${outcome.error ? `: ${outcome.error}` : ''}`);
  }
}
await browser.close();

if (failed) console.log(`${failed} scenario(s) did not pass`);
else if (MODE === 'record') console.log(`All ${scenarios.length} scenarios recorded`);
else console.log(`${scenarios.length - changed} of ${scenarios.length} scenarios match the golden results${changed ? `; ${changed} changed as expected` : ''}`);
process.exit(failed ? 1 : 0);
