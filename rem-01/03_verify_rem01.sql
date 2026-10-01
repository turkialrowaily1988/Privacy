-- REM-01 / F-01 verification (read-only; run as postgres). Expected values in comments.

-- V1: authenticated has no privileges on any relation in public            -> 0
select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relkind in ('r','v','m','p','f','S')
  and (has_table_privilege('authenticated',c.oid,'SELECT') or has_table_privilege('authenticated',c.oid,'INSERT')
    or has_table_privilege('authenticated',c.oid,'UPDATE') or has_table_privilege('authenticated',c.oid,'DELETE'));

-- V2: SECURITY DEFINER functions callable by authenticated                 -> only the 21 gated ones:
--     agent_admin_* (7), agent_console_* (9), rpc_owner_platform_health_v1..v3,
--     check_my_dashboard_access, is_authorized_dashboard_user
select string_agg(p.proname, ',' order by p.proname) from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and p.prokind='f' and p.prosecdef and has_function_privilege('authenticated',p.oid,'EXECUTE');

-- V3: default ACL for future postgres-created tables in public excludes authenticated
select d.defaclacl from pg_default_acl d join pg_namespace n on n.oid=d.defaclnamespace
where n.nspname='public' and pg_get_userbyid(d.defaclrole)='postgres' and d.defaclobjtype in ('r','S');

-- V4 (simulation, non-admin signed-in account): each must fail with 42501
-- begin; select set_config('request.jwt.claims', json_build_object('sub',<non-admin uuid>,'role','authenticated')::text, true);
-- set local role authenticated; select count(*) from public.v_tickets_unified; rollback;   -- permission denied

-- V5 (simulation, Owner admin aal2): rpc_owner_platform_health_v3() returns data; agent_console_whoami() status ok role admin
