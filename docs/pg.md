**For Chains txt2sql:**

1. Create a limited rights user
1. Define secrets for that user `CHAINS_DB_USERNAME` / `CHAINS_DB_PASSWORD`
1. Use those secrets in chains

**PG steps:**

1. CREATE USER username WITH PASSWORD 'secret';
1. GRANT CONNECT ON DATABASE databasename TO username;
1. GRANT USAGE ON SCHEMA public TO username;
1. GRANT SELECT ON tablename TO username;

