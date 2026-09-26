# Database

The pristine database is `livestock.db`, built from `schema.sql` and `seed.sql`. Never edit it by hand. To rebuild it on a Mac, from this folder:

    rm -f livestock.db && sqlite3 livestock.db < schema.sql && sqlite3 livestock.db < seed.sql

The legacy app works on a copy, placed in its `App_Data` folder at build time, so the pristine file is never changed by a run.
