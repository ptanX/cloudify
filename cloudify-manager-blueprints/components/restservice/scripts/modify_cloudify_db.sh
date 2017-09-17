function modify_cloudify_db() {
    sudo -u postgres -H -- psql -d cloudify_db -c "create table vims(_storage_id integer PRIMARY KEY NOT NULL, id text NOT NULL, type text NOT NULL, username text NOT NULL, password text NOT NULL, vim_tenant text NOT NULL, domain_name text, auth_url text NOT NULL, region text NOT NULL, nova_url text NOT NULL, neutron_url text NOT NULL, keypair_name text NOT NULL, private_key_path text NOT NULL, network_name text NOT NULL,private_resource boolean NOT NULL, _tenant_id integer references tenants(id), _creator_id integer references users(id));"
    sudo -u postgres -H -- psql -d cloudify_db -c "GRANT ALL PRIVILEGES ON TABLE vims TO cloudify;"
    sudo -u postgres -H -- psql -d cloudify_db -c "create sequence vims__storage_id_seq;"
    sudo -u postgres -H -- psql -d cloudify_db -c "alter table vims alter _storage_id set default nextval('vims__storage_id_seq');"
    sudo -u postgres -H -- psql -d cloudify_db -c "GRANT USAGE, SELECT ON SEQUENCE vims__storage_id_seq TO cloudify;"
}
modify_cloudify_db
