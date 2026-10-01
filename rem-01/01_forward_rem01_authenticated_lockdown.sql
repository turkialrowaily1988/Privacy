-- REM-01 / F-01 -- authenticated-surface lockdown (Step 1 of the Agent Console plan)
-- Project: yczzpmklidqwfcfsmiva (Production). Applied as role postgres.
--
-- WHAT: the `authenticated` role (any signed-in Supabase account) loses direct
--       Data API access to every table, view and sequence in schema `public`,
--       and EXECUTE on 24 ungated dashboard functions. Default privileges for
--       future tables/sequences created by postgres in `public` stop granting
--       to `authenticated`.
-- WHY:  before this change any signed-in account (not only the Owner) could read
--       tickets, customer memory, pilot identities, CSAT, audit logs, etc.
--       directly, bypassing the Agent Console per-case controls.
-- KEPT: agent_console_* / agent_admin_* (gated by agent_iam: email+TOTP+member+
--       role+assignment), rpc_owner_platform_health_v1..v3 (gated by
--       dashboard_users admin), check_my_dashboard_access,
--       is_authorized_dashboard_user, trivial helpers.
-- NOT TOUCHED: anon, service_role, n8n, Edge Functions, RLS policies, views,
--       function bodies, Auth, rt_v3, agent_iam, customer path.

REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM authenticated;  -- includes views + materialized views
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM authenticated;

REVOKE EXECUTE ON FUNCTION
  public.check_csat_exists(p_ticket_id text),
  public.csat_kpi_overview(p_tenant_id text),
  public.get_ai_accuracy(),
  public.get_cc_ai(),
  public.get_cc_alerts(),
  public.get_cc_degraded(),
  public.get_cc_overview(),
  public.get_cc_pipeline(),
  public.get_cc_reliability(),
  public.get_cc_sla(),
  public.get_csat_overview_v2(p_tenant_id text, p_is_test boolean),
  public.get_dashboard_kpis(),
  public.get_dashboard_kpis_v2(p_is_test boolean),
  public.get_escalation_trend(),
  public.get_escalation_trend_v2(p_is_test boolean),
  public.get_escalation_trends(),
  public.get_executive_summary(),
  public.get_hourly_volume(),
  public.get_intent_distribution(),
  public.get_intent_distribution_v2(p_is_test boolean),
  public.get_latency_summary(),
  public.get_resolution_time(),
  public.get_sla_compliance(),
  public.meta_kpi_overview()
FROM authenticated;

-- Stop future tables/sequences in `public` (created by postgres) from silently re-opening the surface.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES    FROM authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON SEQUENCES FROM authenticated;
