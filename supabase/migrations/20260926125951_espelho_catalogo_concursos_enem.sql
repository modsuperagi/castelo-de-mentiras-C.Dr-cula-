-- Radar do Sonar (26/09): concursos com edital aberto (Seduc CE, Sesa AP, PM AL, Detran SP, Emater MG) e ENEM em 8 e 15/11.
-- Concurseiros já usam IA para gerar questões de lei seca; o risco é a lei ou a súmula inventada.
-- A oferta: o organismo entrega por etapas, com a base legal conferida na fonte oficial (P0).
INSERT INTO public.espelho_catalogo (pacote,nome,valor_centavos,recorrente,pix_automatico,material,prazo,limites,ordem) VALUES
 ('plano_concurso','Plano Concursos · por etapas',3900,true,true,
  'No mesmo e-mail, mande o link do edital, o cargo e quantas horas por semana você consegue estudar.',
  'A 1ª etapa (mapa do edital e cronograma) chega em até 48 horas; depois, toda segunda-feira, a etapa da semana. O plano vale 30 dias; para cancelar, responda CANCELAR.',
  '{"mapa_edital":1,"semanas":4,"questoes_por_semana":30,"correcoes_por_semana":1,"radar_edital":true}',45),
 ('concurso_mapa','Mapa do Edital',2900,false,true,
  'No mesmo e-mail, mande o link ou o PDF do edital, o cargo, a data da prova (se já saiu) e quantas horas por semana você consegue estudar.',
  'O mapa do edital e o cronograma até a prova chegam em até 48 horas.','{}',63),
 ('enem_redacao','Redação ENEM · 4 correções',2900,false,true,
  'No mesmo e-mail, mande a 1ª redação (texto ou foto legível) e o tema. As outras três você manda quando quiser, até a prova.',
  'Cada correção chega em até 24 horas, com nota estimada nas 5 competências (não é a nota oficial do Inep).',
  '{"correcoes":4}',64);

ALTER TABLE public.espelho_uso DROP CONSTRAINT espelho_uso_tipo_check;
ALTER TABLE public.espelho_uso ADD CONSTRAINT espelho_uso_tipo_check
  CHECK (tipo = ANY (ARRAY['checagem','investigacao','mesa','auditoria','roteiros','memoria','etapa_concurso','correcao_redacao']));
