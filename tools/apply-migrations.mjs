// Makes the database the app should run on: a copy of the pristine database with every
// migration in db/migrations applied, in filename order. The pristine database is never changed.
// Usage: node tools/apply-migrations.mjs <output database file>
import { DatabaseSync } from 'node:sqlite';
import { copyFileSync, existsSync, readdirSync, readFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const out = process.argv[2];
if (!out) { console.error('Give the output database file'); process.exit(2); }

copyFileSync(join(repo, 'db', 'livestock.db'), out);
const dir = join(repo, 'db', 'migrations');
const files = existsSync(dir) ? readdirSync(dir).filter((f) => f.endsWith('.sql')).sort() : [];
const db = new DatabaseSync(out);
for (const f of files) {
  console.log(`Applying ${f}`);
  db.exec(readFileSync(join(dir, f), 'utf8'));
}
db.close();
console.log(files.length ? `${files.length} migration(s) applied to ${out}` : `No migrations; ${out} is the pristine database`);
