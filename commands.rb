# Migrate
Sequel::Migrator.apply(DB, './db/migrations')
Sequel::Migrator.apply(DB, './db/migrations')

# Migrate to a specific version
sequel -m './db/migrations' -M 1384799854 'postgres://Andrew@localhost:5432/masterdash'
sequel -m './db/migrations' 'postgres://Andrew@localhost:5432/masterdash'

# Load the postgresql console
psql -h /var/pgsql_socket masterdash

