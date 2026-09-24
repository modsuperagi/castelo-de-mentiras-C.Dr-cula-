-- Migração 20260914194553 · 013_create_simple_views
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Vista: Contagem por Camada de Conhecimento
DROP VIEW IF EXISTS vw_conhecimento_por_camada CASCADE;
CREATE VIEW vw_conhecimento_por_camada AS
SELECT 
  camada,
  COUNT(*) as total_entradas
FROM fluxo_conhecimento
GROUP BY camada;

-- Vista: Total de Decisões Registradas
DROP VIEW IF EXISTS vw_total_decisoes CASCADE;
CREATE VIEW vw_total_decisoes AS
SELECT COUNT(*) as total_decisoes FROM registro_decisoes;

-- Vista: Conhecimento Pendente de Refino
DROP VIEW IF EXISTS vw_proximo_refino CASCADE;
CREATE VIEW vw_proximo_refino AS
SELECT 
  id,
  titulo,
  origem,
  data_entrada,
  responsavel
FROM fluxo_conhecimento
WHERE camada = 'bruto'
ORDER BY data_entrada ASC
LIMIT 10;

-- Vista: Últimas 5 Evoluções
DROP VIEW IF EXISTS vw_ultimas_evolucoes CASCADE;
CREATE VIEW vw_ultimas_evolucoes AS
SELECT 
  versao,
  mudanca,
  responsavel,
  impacto_estimado
FROM registro_evolucoes
ORDER BY data_versao DESC
LIMIT 5;
