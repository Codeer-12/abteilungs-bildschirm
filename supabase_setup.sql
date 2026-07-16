-- =========================================================================
-- Abteilungsbildschirm — Supabase-Setup
-- Ausführen: Supabase Dashboard → SQL Editor → dieses Script einfügen → Run
-- =========================================================================

-- 1) Tabelle für den App-Zustand (eine Zeile, JSON-Dokument)
create table if not exists public.app_state (
  id         text primary key,
  json       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

-- 2) Zugriffsregeln — PROTOTYP-STUFE: offen für anon key.
--    ⚠️ Jeder mit der URL kann lesen UND schreiben. Vor Produktivbetrieb härten
--    (Supabase Auth aktivieren und die Schreib-Policies auf authenticated umstellen).
drop policy if exists "state_select" on public.app_state;
drop policy if exists "state_insert" on public.app_state;
drop policy if exists "state_update" on public.app_state;

create policy "state_select" on public.app_state for select using (true);
create policy "state_insert" on public.app_state for insert with check (true);
create policy "state_update" on public.app_state for update using (true);

-- 3) Realtime für die Tabelle aktivieren (Live-Sync auf alle Bildschirme)
do $$
begin
  alter publication supabase_realtime add table public.app_state;
exception when duplicate_object then null;
end $$;

-- 4) Storage-Bucket für Dokument-Dateien (öffentlich lesbar)
insert into storage.buckets (id, name, public)
values ('dokumente', 'dokumente', true)
on conflict (id) do nothing;

-- 5) Storage-Zugriffsregeln (Prototyp: anon darf hochladen/löschen)
drop policy if exists "docs_select" on storage.objects;
drop policy if exists "docs_insert" on storage.objects;
drop policy if exists "docs_update" on storage.objects;
drop policy if exists "docs_delete" on storage.objects;

create policy "docs_select" on storage.objects for select using (bucket_id = 'dokumente');
create policy "docs_insert" on storage.objects for insert with check (bucket_id = 'dokumente');
create policy "docs_update" on storage.objects for update using (bucket_id = 'dokumente');
create policy "docs_delete" on storage.objects for delete using (bucket_id = 'dokumente');

-- =========================================================================
-- Fertig. Danach in index.html eintragen (Block `const BACKEND`):
--   url:     'https://<projekt-ref>.supabase.co'   (Settings → API → Project URL)
--   anonKey: '<anon public key>'                    (Settings → API → anon key)
-- =========================================================================

-- ---------------------------------------------------------------------
-- SPÄTER (Produktiv-Härtung, noch NICHT ausführen):
-- Schreibrechte nur für angemeldete Benutzer:
--   drop policy "state_insert" on public.app_state;
--   drop policy "state_update" on public.app_state;
--   create policy "state_insert" on public.app_state for insert to authenticated with check (true);
--   create policy "state_update" on public.app_state for update to authenticated using (true);
--   (analog für storage.objects: docs_insert / docs_update / docs_delete)
-- ---------------------------------------------------------------------
