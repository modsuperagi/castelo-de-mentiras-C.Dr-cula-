-- Migração 20260814025506 · blindar_arquivo_primordial_minima_galaxia
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

alter table public.meta_lab_entries add column if not exists origem_banca text;

alter table public.meta_lab_entries drop constraint if exists meta_lab_entries_origem_banca_check;
alter table public.meta_lab_entries add constraint meta_lab_entries_origem_banca_check check (origem_banca in ('BANCA_1','BANCA_2_SUPER_POWER'));

comment on column public.meta_lab_entries.origem_banca is 'Selo de origem da banca. Obrigatório para registros arquivados da arquitetura EVO.';
comment on table public.meta_lab_versoes is 'IMUTÁVEL: snapshots são testemunhas históricas. UPDATE e DELETE proibidos; novas versões somente por INSERT.';

create or replace function public.bloquear_alteracao_snapshot_evo()
returns trigger
language plpgsql
as $$
begin
  raise exception 'SNAPSHOT_IMUTAVEL: meta_lab_versoes aceita somente INSERT de novas versões.';
end;
$$;

drop trigger if exists trg_meta_lab_versoes_immutavel on public.meta_lab_versoes;
create trigger trg_meta_lab_versoes_immutavel
before update or delete on public.meta_lab_versoes
for each row execute function public.bloquear_alteracao_snapshot_evo();

comment on function public.bloquear_alteracao_snapshot_evo() is 'Proteção EVO: impede UPDATE/DELETE de snapshots; evolução histórica somente por INSERT.';
