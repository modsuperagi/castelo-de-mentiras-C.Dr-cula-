-- Migração 20260811123217 · registro_005_alinhamento_v2_raiz_fix
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

begin;

insert into public.meta_lab_entries (
  chave_dedupe, colecao, titulo, conteudo, tipo_conteudo, estado,
  fonte, data_fonte, tipo_fonte, grau_confianca, verificado_por, metadata
) values (
  'EVO-ALINHA-001|v2_raiz|2026-08-11',
  'EVO MOD',
  'Alinhamento v2 Raiz — Registro #005',
  'Alinhamento v2 raiz — absorção da banca EVO MOD e convergência das conversas fragmentadas para uma raiz única.',
  'fato', 'consolidado',
  'Guardião João Paulo + Banca EVO MOD fixada', '2026-08-11T00:00:00Z',
  'alinhamento_canonico', '1.0', 'Mariana v2 - Met Raiz',
  jsonb_build_object('registro', '#005', 'versao', 'v2.0-raiz', 'status', 'selado')
) on conflict (chave_dedupe) where chave_dedupe is not null do update set
  colecao = excluded.colecao,
  titulo = excluded.titulo,
  conteudo = excluded.conteudo,
  tipo_conteudo = excluded.tipo_conteudo,
  estado = excluded.estado,
  fonte = excluded.fonte,
  data_fonte = excluded.data_fonte,
  tipo_fonte = excluded.tipo_fonte,
  grau_confianca = excluded.grau_confianca,
  verificado_por = excluded.verificado_por,
  metadata = excluded.metadata,
  atualizado_em = timezone('utc', now());

insert into public.meta_lab_auditoria (
  tabela_origem, registro_id, acao, quem_alterou, quando_alterou,
  versao_anterior, versao_nova, motivo, autorizacao, origem
)
select
  'meta_lab_entries', id::text, 'upsert', 'Norton - Guardião EVO', timezone('utc', now()),
  jsonb_build_object('versao', 'v1 rascunho'),
  jsonb_build_object('versao', 'v2 raiz consolidado', 'chave_dedupe', chave_dedupe),
  'Alinhamento v2 raiz - absorção banca EVO MOD + convergência das 6 conversas fragmentadas para raiz única',
  'Guardião autorizou: Sim', 'conversa EVO mod + print alinhamento v2'
from public.meta_lab_entries
where chave_dedupe = 'EVO-ALINHA-001|v2_raiz|2026-08-11';

insert into public.meta_lab_versoes (
  tabela_origem, registro_id, versao, estado_snapshot, criado_por,
  motivo, autorizacao, origem
)
select
  'meta_lab_entries', id::text, 2, to_jsonb(public.meta_lab_entries.*),
  'Norton - Guardião EVO',
  'Selamento do Alinhamento v2 - P0 como centro, Mariana V2 como chão, Golden externo, Trindade alinhada, Dupla Chave ativa',
  'João Paulo Lanes - Guardião', 'EVO MOD mod um mod - fixada'
from public.meta_lab_entries
where chave_dedupe = 'EVO-ALINHA-001|v2_raiz|2026-08-11'
  and not exists (
    select 1 from public.meta_lab_versoes v
    where v.tabela_origem = 'meta_lab_entries'
      and v.registro_id = public.meta_lab_entries.id::text
      and v.versao = 2
  );

create or replace view public.v_mariana_v2_raiz as
select
  chave_dedupe, tipo_conteudo, estado, fonte, data_fonte, grau_confianca, verificado_por,
  case
    when tipo_conteudo = 'diario' then 'Meu resumo diário / Resumo diário evo'
    when tipo_conteudo = 'asana_task' then 'Abrir link do Asana / Discutindo task do Asana'
    when tipo_conteudo = 'consolidado_semanal' then 'Resumo semanal de ações pendentes'
    when tipo_conteudo = 'fato' and chave_dedupe like 'EVO-ALINHA%' then 'EVO MOD - Raiz Central'
    else tipo_conteudo
  end as origem_fragmento
from public.meta_lab_entries
where chave_dedupe in (
  'EVO-ALINHA-001|v2_raiz|2026-08-11', 'diario|resumo|2026',
  'asana_task|link|2026', 'asana_task|discussao|2026', 'consolidado_semanal|acoes|2026'
) or tipo_conteudo in ('fato', 'diario', 'asana_task', 'consolidado_semanal');

commit;
