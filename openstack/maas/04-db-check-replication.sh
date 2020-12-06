sudo -u postgres psql -c "select usename, application_name, client_addr, state, sync_priority, sync_state from pg_stat_replication;"
