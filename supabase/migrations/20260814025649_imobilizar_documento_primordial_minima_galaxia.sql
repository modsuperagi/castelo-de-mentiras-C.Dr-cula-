-- Migração 20260814025649 · imobilizar_documento_primordial_minima_galaxia
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.bloquear_arquivo_primordial_minima_galaxia()
returns trigger
language plpgsql
as $$
begin
  if old.chave_dedupe = 'EVO-MG-ARQUIVO-PRIMORDIAL-v7.1-2026-07-31' then
    raise exception 'ARQUIVO_PRIMORDIAL_IMUTAVEL: a Teoria da Mínima Galáxia v7.1 é testemunha histórica; alterações devem ser feitas em registros derivados de pesquisa.';
  end if;
  return coalesce(new,old);
end;
$$;

drop trigger if exists trg_minima_galaxia_primordial_immutavel on public.meta_lab_entries;
create trigger trg_minima_galaxia_primordial_immutavel
before update or delete on public.meta_lab_entries
for each row execute function public.bloquear_arquivo_primordial_minima_galaxia();

comment on function public.bloquear_arquivo_primordial_minima_galaxia() is 'Exceção EVO para a pesquisa científica: o documento primordial da Mínima Galáxia é imutável; hipóteses, testes e revisões usam novos registros derivados.';
