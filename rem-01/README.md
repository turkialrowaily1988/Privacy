# REM-01 / F-01 — authenticated-surface lockdown (Step 1)

Applied to Supabase project `yczzpmklidqwfcfsmiva` on 2026-10-01 21:42 UTC as migration
`rem01_f01_authenticated_surface_lockdown` (version 20261001214226).

| File | Purpose |
|---|---|
| `01_forward_rem01_authenticated_lockdown.sql` | Exact change applied |
| `02_rollback_rem01_authenticated_lockdown.sql` | Exact pre-change grants (128 GRANTs + default privileges) |
| `03_verify_rem01.sql` | Read-only verification queries and expected results |

Evidence (simulated PostgREST role + JWT claims, inside rolled-back transactions):

| Check | Before | After |
|---|---|---|
| Non-admin signed-in account: `v_tickets_unified` | 278 rows readable | 42501 permission denied |
| Non-admin: `memory` (customer memory) | 791 rows | 42501 |
| Non-admin: `pilot_identities` | 30 rows | 42501 |
| Non-admin: `audit_logs` | 2,002 rows | 42501 |
| Non-admin: `get_cc_overview()` | data returned | 42501 |
| Non-admin: `rpc_owner_platform_health_v3()` | (gated) | 42501 not authorized |
| Non-admin: agent console RPCs | – | `no_membership` / `denied` |
| Owner admin: owner health v3 / dashboard access / agent console admin | OK | OK (48 cases visible, members OK) |
| service_role (n8n): views, tables, `rt3_put_ticket`, `sync_ticket_resolution` | OK | OK |
| anon | unchanged | unchanged |
