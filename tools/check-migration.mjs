// Checks the joint keepers migration kept every existing keeper:
// every animal has exactly one keeper, marked primary, it is the keeper the animal had before,
// and it is dated from the Regulations' commencement date (see docs/joint-keepers-law.md).
// Usage: node tools/check-migration.mjs <migrated database file>
import { DatabaseSync } from 'node:sqlite';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const COMMENCEMENT = '2026-10-01';
const repo = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const migratedFile = process.argv[2];
if (!migratedFile) { console.error('Give the migrated database file'); process.exit(2); }

const before = new DatabaseSync(join(repo, 'db', 'livestock.db'), { readOnly: true });
const after = new DatabaseSync(migratedFile, { readOnly: true });
const failures = [];
const expect = (ok, what) => { if (!ok) failures.push(what); };

const hasTable = after.prepare("SELECT COUNT(*) AS n FROM sqlite_master WHERE type = 'table' AND name = 'AnimalKeeper'").get().n === 1;
expect(hasTable, 'the AnimalKeeper table exists');
if (hasTable) {
  const animalColumns = after.prepare('PRAGMA table_info(Animal)').all().map((c) => c.name);
  expect(!animalColumns.includes('KeeperId'), 'Animal no longer has a KeeperId column');

  const old = before.prepare('SELECT AnimalId, KeeperId FROM Animal ORDER BY AnimalId').all();
  const nowAnimals = after.prepare('SELECT COUNT(*) AS n FROM Animal').get().n;
  expect(nowAnimals === old.length, `all ${old.length} animals are still there (found ${nowAnimals})`);
  for (const a of old) {
    const rows = after.prepare('SELECT KeeperId, IsPrimary, DateAdded FROM AnimalKeeper WHERE AnimalId = ?').all(a.AnimalId);
    const ok = rows.length === 1 && rows[0].KeeperId === a.KeeperId && Number(rows[0].IsPrimary) === 1 && rows[0].DateAdded === COMMENCEMENT;
    expect(ok, `animal ${a.AnimalId} has exactly one keeper, its previous keeper ${a.KeeperId}, as primary, dated ${COMMENCEMENT} (found ${JSON.stringify(rows)})`);
  }
}
before.close(); after.close();

if (failures.length) {
  for (const f of failures.slice(0, 10)) console.log(`FAIL  ${f}`);
  if (failures.length > 10) console.log(`...and ${failures.length - 10} more`);
  process.exit(1);
}
console.log('PASS  every animal kept its keeper, now as its primary keeper, dated from commencement');
