-- Migração 20260911052710 · 002_castelo_memorias_fluxo_continuo
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================
-- CASTELO DE MEMÓRIAS (Tríade)
-- ========================================
-- Preserva: identidade + determinação + conhecimento + ideologia + feitos + história
-- NÃO substitui pessoa por conhecimento
-- Oferece material para autorreconhecimento

CREATE TABLE IF NOT EXISTS public.castelo_identidades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  -- IDENTIDADE
  nome_original TEXT NOT NULL,
  epoca_ativa TEXT,
  contexto_historico TEXT,
  caracteristicas_reconheciveis JSONB DEFAULT '[]'::jsonb,
  trajetoria TEXT,
  
  -- DETERMINAÇÃO
  objetivo_declarado TEXT,
  desejo_profundo TEXT,
  problemas_buscava_solucionar JSONB DEFAULT '[]'::jsonb,
  aquilo_que_recusava TEXT,
  aquilo_que_defendia TEXT,
  
  -- CONHECIMENTO
  teorias JSONB DEFAULT '[]'::jsonb,
  tecnicas JSONB DEFAULT '[]'::jsonb,
  conceitos JSONB DEFAULT '[]'::jsonb,
  descobertas JSONB DEFAULT '[]'::jsonb,
  metodos TEXT,
  obras JSONB DEFAULT '[]'::jsonb,
  
  -- IDEOLOGIA
  principios JSONB DEFAULT '[]'::jsonb,
  valores TEXT,
  visao_de_mundo TEXT,
  fundamentos_decisao TEXT,
  
  -- FEITOS
  realizacoes_documentadas JSONB DEFAULT '[]'::jsonb,
  experimentos JSONB DEFAULT '[]'::jsonb,
  descobertas_feitos JSONB DEFAULT '[]'::jsonb,
  decisoes_marcantes JSONB DEFAULT '[]'::jsonb,
  consequencias_observadas TEXT,
  
  -- MEMÓRIA HISTÓRICA
  testemunhos JSONB DEFAULT '[]'::jsonb,
  documentos_fontes JSONB DEFAULT '[]'::jsonb,
  criticas_recebidas JSONB DEFAULT '[]'::jsonb,
  acontecimentos_posteriores JSONB DEFAULT '[]'::jsonb,
  impactos TEXT,
  apropriações TEXT,
  distorções TEXT,
  
  -- LIMITES (o que NÃO sabemos)
  desconhecido TEXT,
  controverso TEXT,
  sem_registro_suficiente TEXT,
  nao_pode_ser_reconstruido TEXT,
  
  status_castelo VARCHAR(50) DEFAULT 'fundamentacao' CHECK (status_castelo IN ('fundamentacao', 'recrutado', 'estudo_ativo', 'autoreconhecimento', 'participante')),
  validado_em TIMESTAMP,
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- ========================================
-- SESSÕES DE ESTUDO (investigação profunda)
-- ========================================
-- Escavação histórica da identidade
-- Rastreia: fontes, evidências, contexto, interpretações, lacunas

CREATE TABLE IF NOT EXISTS public.sessoes_estudo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  castelo_id UUID NOT NULL,
  
  titulo_questao TEXT NOT NULL,
  descricao_investigacao TEXT,
  topico_investigado VARCHAR(255), -- ex: "relação com esposa", "descoberta científica"
  
  -- INVESTIGAÇÃO (7 camadas)
  quem_afirmou TEXT,
  qual_fonte TEXT,
  qual_evidencia TEXT,
  quais_fontes_discordam JSONB DEFAULT '[]'::jsonb,
  contexto_historico TEXT,
  que_esta_documentado TEXT,
  que_e_interpretacao TEXT,
  que_permanece_especulacao TEXT,
  
  conclusao_raiz TEXT,
  grau_confianca VARCHAR(50) DEFAULT 'parcial' CHECK (grau_confianca IN ('alto', 'medio', 'baixo', 'parcial', 'controverso')),
  
  status_estudo VARCHAR(50) DEFAULT 'aberta' CHECK (status_estudo IN ('aberta', 'em_investigacao', 'evidencia_encontrada', 'inconclusiva', 'refutada', 'confirmada')),
  iniciada_em TIMESTAMP DEFAULT NOW(),
  encerrada_em TIMESTAMP,
  investigador TEXT,
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT castelo_fk FOREIGN KEY (castelo_id) REFERENCES public.castelo_identidades(id) ON DELETE CASCADE
);

-- ========================================
-- VALIDAÇÕES OBRIGATÓRIAS (Clareza > Velocidade > Escala)
-- ========================================
-- Toda entrada passa por 3 validações ANTES de circulação

CREATE TABLE IF NOT EXISTS public.validacoes_obrigatorias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  flow_id UUID NOT NULL,
  
  -- VALIDAÇÃO 1: MANTÉM O PROPÓSITO?
  v1_propositum BOOLEAN NOT NULL,
  v1_evidencia TEXT,
  v1_motivo TEXT,
  
  -- VALIDAÇÃO 2: EXISTE EVIDÊNCIA?
  v2_evidencia BOOLEAN NOT NULL,
  v2_fonte TEXT,
  v2_descricao TEXT,
  v2_grau_confianca VARCHAR(50),
  
  -- VALIDAÇÃO 3: QUAL IMPACTO?
  v3_impacto BOOLEAN NOT NULL,
  v3_descricao_impacto TEXT,
  v3_escopo TEXT, -- breve, indireto, reversível, permanente
  v3_consequencias TEXT,
  
  -- RESULTADO AGREGADO
  todas_passaram BOOLEAN GENERATED ALWAYS AS (v1_propositum AND v2_evidencia AND v3_impacto) STORED,
  validado_em TIMESTAMP DEFAULT NOW(),
  validado_por TEXT,
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- ========================================
-- FLUXO DE CONHECIMENTO (Kanban contínuo)
-- ========================================
-- Camadas: bruto → refinado → transmissível
-- Cada entrada pode progredir, regredir, ou ramificar

CREATE TABLE IF NOT EXISTS public.fluxo_conhecimento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  titulo TEXT NOT NULL,
  origem TEXT,
  data_entrada TIMESTAMP DEFAULT NOW(),
  camada VARCHAR(50) NOT NULL CHECK (camada IN ('bruto', 'refinado', 'transmissível', 'ensino', 'produto')),
  
  conteudo TEXT,
  conexoes JSONB DEFAULT '[]'::jsonb, -- IDs de outras entradas relacionadas
  aprendizado TEXT,
  tags JSONB DEFAULT '[]'::jsonb,
  responsavel TEXT,
  
  data_refino TIMESTAMP,
  data_transmissao TIMESTAMP,
  
  -- RASTREABILIDADE
  sessao_estudo_id UUID REFERENCES public.sessoes_estudo(id),
  validacao_id UUID REFERENCES public.validacoes_obrigatorias(id),
  
  status VARCHAR(50) DEFAULT 'ativo' CHECK (status IN ('ativo', 'revisao', 'descontinuado', 'arquivado')),
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- ========================================
-- CONSEQUÊNCIAS HISTÓRICAS (O QUE ACONTECEU DEPOIS)
-- ========================================
-- Permite que o passado receba informação do futuro

CREATE TABLE IF NOT EXISTS public.consequencias_historicas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  castelo_id UUID NOT NULL,
  
  tipo_consequencia VARCHAR(100), -- descoberta_derivada, aplicacao, refutacao, desenvolvimento, etc
  descricao TEXT,
  data_descoberta TIMESTAMP,
  fontes JSONB DEFAULT '[]'::jsonb,
  evidencia TEXT,
  
  impacto_cientifico TEXT,
  impacto_tecnologico TEXT,
  impacto_social TEXT,
  impacto_politico TEXT,
  impacto_cultural TEXT,
  
  confirmou_ou_contrariou VARCHAR(50) CHECK (confirmou_ou_contrariou IN ('confirmou', 'contrariou', 'expandiu', 'refutou', 'neutralizou')),
  
  criado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT castelo_fk FOREIGN KEY (castelo_id) REFERENCES public.castelo_identidades(id) ON DELETE CASCADE
);

-- ========================================
-- EVO PILARES (6 estruturas principais)
-- ========================================

-- EVO 1: GUARDIÃO (princípios — só edição admin)
CREATE TABLE IF NOT EXISTS public.evo_principios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  principio TEXT NOT NULL UNIQUE,
  descricao TEXT,
  validacao_1_propositum BOOLEAN,
  validacao_2_evidencia BOOLEAN,
  validacao_3_impacto BOOLEAN,
  ativo BOOLEAN DEFAULT TRUE,
  responsavel TEXT DEFAULT 'Guardião',
  
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- EVO 4: GOLDEN (decisões — fonte única da verdade, imutável)
CREATE TABLE IF NOT EXISTS public.registro_decisoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  decisao TEXT NOT NULL,
  motivo TEXT,
  mudanca TEXT,
  data_decisao TIMESTAMP DEFAULT NOW(),
  responsavel TEXT,
  nivel_acesso VARCHAR(50) CHECK (nivel_acesso IN ('nucleo', 'confianca', 'estrutura', 'publico')),
  link TEXT,
  status VARCHAR(50) DEFAULT 'ativa' CHECK (status IN ('ativa', 'revisada', 'descontinuada')),
  relacionado_a_conhecimento UUID REFERENCES public.fluxo_conhecimento(id),
  relacionado_a_agente UUID,
  
  criado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- EVO 6: CONSOLIDAÇÃO (notas)
CREATE TABLE IF NOT EXISTS public.notas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  titulo TEXT NOT NULL,
  corpo TEXT,
  categoria_evo VARCHAR(50) CHECK (categoria_evo IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
  tags JSONB DEFAULT '[]'::jsonb,
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_atualizacao TIMESTAMP DEFAULT NOW(),
  status VARCHAR(50) DEFAULT 'ativa' CHECK (status IN ('ativa', 'revisao', 'arquivada')),
  relacionado_a_conhecimento UUID REFERENCES public.fluxo_conhecimento(id),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- EVO 2: FUNDADORA (agentes)
CREATE TABLE IF NOT EXISTS public.agentes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  nome TEXT NOT NULL,
  camada_evo VARCHAR(50) CHECK (camada_evo IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
  funcao TEXT,
  status_ativo BOOLEAN DEFAULT TRUE,
  comandos_permitidos JSONB DEFAULT '[]'::jsonb,
  ultima_acao TIMESTAMP,
  
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- EVO 5: METODOLOGIA (evoluções com versionamento semântico)
CREATE TABLE IF NOT EXISTS public.registro_evolucoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  versao VARCHAR(50), -- semantic version
  mudanca TEXT,
  data_evolucao TIMESTAMP DEFAULT NOW(),
  responsavel TEXT,
  impacto TEXT,
  validado_por_guardiao BOOLEAN DEFAULT FALSE,
  
  criado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- ACESSOS E CANAIS (restrito a núcleo)
CREATE TABLE IF NOT EXISTS public.acessos_canais (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  canal TEXT NOT NULL,
  descricao TEXT,
  nivel_acesso VARCHAR(50) CHECK (nivel_acesso IN ('nucleo', 'confianca', 'estrutura', 'publico')),
  link TEXT,
  responsavel TEXT,
  data_criacao TIMESTAMP DEFAULT NOW(),
  ativo BOOLEAN DEFAULT TRUE,
  
  CONSTRAINT fio_id_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- ========================================
-- ÍNDICES PARA FLUXO CONTÍNUO
-- ========================================

CREATE INDEX IF NOT EXISTS idx_castelo_status ON public.castelo_identidades(status_castelo, criado_em DESC);
CREATE INDEX IF NOT EXISTS idx_sessao_estudo_castelo ON public.sessoes_estudo(castelo_id, status_estudo);
CREATE INDEX IF NOT EXISTS idx_validacao_flow ON public.validacoes_obrigatorias(flow_id, todas_passaram);
CREATE INDEX IF NOT EXISTS idx_conhecimento_camada ON public.fluxo_conhecimento(camada, status, atualizado_em DESC);
CREATE INDEX IF NOT EXISTS idx_conhecimento_tags ON public.fluxo_conhecimento USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_consequencias_castelo ON public.consequencias_historicas(castelo_id, data_descoberta DESC);
CREATE INDEX IF NOT EXISTS idx_principios_ativo ON public.evo_principios(ativo, criado_em DESC);
CREATE INDEX IF NOT EXISTS idx_decisoes_status ON public.registro_decisoes(status, nivel_acesso, data_decisao DESC);
CREATE INDEX IF NOT EXISTS idx_notas_categoria ON public.notas(categoria_evo, status, data_atualizacao DESC);
CREATE INDEX IF NOT EXISTS idx_agentes_evo ON public.agentes(camada_evo, status_ativo);
CREATE INDEX IF NOT EXISTS idx_evolucoes_versao ON public.registro_evolucoes(versao, data_evolucao DESC);

COMMIT;
