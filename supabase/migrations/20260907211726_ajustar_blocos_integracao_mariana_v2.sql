-- Migração 20260907211726 · ajustar_blocos_integracao_mariana_v2
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace view public.v_mariana_v2_integracao as
select
  case
    when titulo ilike '%Alinhamento v2 Raiz%' or titulo ilike '%Snapshot Estrutural%' then '01_identidade'
    when titulo ilike '%R1 GOVERNANÇA TRINA%' or titulo ilike '%STATUS QUO%' then '02_linhagem'
    when titulo ilike '%governança%' or titulo ilike '%PLASMA%' or titulo ilike '%NÚCLEO METODOLÓGICO%' then '03_governanca'
    when titulo ilike '%MESA%' or titulo ilike '%plugins%' or titulo ilike '%LOCAL-FIRST%' or titulo ilike '%Delegação e Núcleos%' then '04_circulacao'
    when titulo ilike '%CURIOSIDADE%' or titulo ilike '%PEDIDO%' or titulo ilike '%CHECKPOINT%' or titulo ilike '%RESULTADO%' or titulo ilike '%Golden%' then '06_decisao'
    when titulo ilike '%Mínima Galáxia%' or titulo ilike '%GLOSSÁRIO%' or titulo ilike '%Neurociência%' or titulo ilike '%CORPUS DE IMAGENS%' then '05_conhecimento'
    else '07_consolidacao'
  end as bloco,
  id,
  titulo,
  tipo_conteudo,
  estado,
  chave_dedupe,
  fonte,
  data_fonte,
  grau_confianca,
  verificado_por,
  origem_banca,
  criado_em
from public.meta_lab_entries;

comment on view public.v_mariana_v2_integracao is 'Mapa relacional de registros existentes para agregacao operacional do eixo Mariana V2. Nao duplica dados, nao afirma pertencimento ontologico ao nucleo e nao substitui P0.';
