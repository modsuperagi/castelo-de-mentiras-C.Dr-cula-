// xAI SIMULADA, só para testes do encanamento (servidor, síntese, tela).
// Imita o formato documentado da Responses API. Não prova nada sobre a API real:
// passar nestes testes NÃO valida a integração com a xAI.

import { createServer } from 'node:http';

export const RESPOSTA_EXEMPLO = {
  id: 'resp_simulada',
  object: 'response',
  model: 'grok-simulado',
  output: [
    { type: 'web_search_call', id: 'ws_1', status: 'completed', action: { type: 'search', query: 'exemplo tecnologia novidades semana' } },
    { type: 'custom_tool_call', id: 'xs_1', name: 'x_keyword_search', input: '{"query":"exemplo tecnologia lançamento"}' },
    {
      type: 'message',
      role: 'assistant',
      content: [{
        type: 'output_text',
        text: JSON.stringify({
          resumo: 'A versão 2.0 da tecnologia Exemplo saiu nesta semana, segundo o anúncio oficial [[1]](https://exemplo.org/blog/versao-2).',
          achados: [
            { texto: 'A versão 2.0 foi lançada em 22/09.', tipo: 'fato', fontes: ['https://exemplo.org/blog/versao-2', 'https://noticias.example.com/exemplo-2'] },
            { texto: 'Um desenvolvedor afirma que o desempenho dobrou.', tipo: 'afirmacao', fontes: ['https://x.com/dev/status/1'] },
            { texto: 'A adoção deve crescer.', tipo: 'fato', fontes: ['https://inventada.example.net/nao-existe'] },
          ],
          cruzamento: {
            convergencias: [{ texto: 'Anúncio oficial e imprensa concordam na data.', fontes: ['https://exemplo.org/blog/versao-2', 'https://noticias.example.com/exemplo-2'] }],
            divergencias: [{ tema: 'Ganho de desempenho', posicoes: [
              { texto: 'O anúncio fala em 30% mais rápido.', fontes: ['https://exemplo.org/blog/versao-2'] },
              { texto: 'Um post no X fala em o dobro.', fontes: ['https://x.com/dev/status/1'] },
            ] }],
          },
          pontos_de_atencao: ['Não há medição independente do desempenho.'],
          evidencia: 'suficiente',
        }),
        annotations: [{ type: 'url_citation', url: 'https://exemplo.org/blog/versao-2', title: 'Exemplo 2.0 chegou' }],
      }],
    },
  ],
  citations: [
    'https://exemplo.org/blog/versao-2',
    'https://noticias.example.com/exemplo-2',
    'https://x.com/dev/status/1',
    'https://outra.example.com/consultada',
  ],
  usage: { input_tokens: 1200, output_tokens: 400, total_tokens: 1600 },
  server_side_tool_usage: { SERVER_SIDE_TOOL_WEB_SEARCH: 1, SERVER_SIDE_TOOL_X_SEARCH: 1 },
};

// comportamento(corpo) → { status, json } ; guarda os pedidos recebidos em `pedidos`.
export function iniciarXaiSimulada(comportamento = () => ({ status: 200, json: RESPOSTA_EXEMPLO })) {
  const pedidos = [];
  const servidor = createServer(async (req, res) => {
    let texto = '';
    for await (const p of req) texto += p;
    const corpo = JSON.parse(texto || '{}');
    pedidos.push({ caminho: req.url, autorizacao: req.headers.authorization, corpo });
    const { status, json, atraso = 0 } = comportamento(corpo, pedidos.length);
    await new Promise((r) => setTimeout(r, atraso));
    res.statusCode = status;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(json));
  });
  return new Promise((resolve) => {
    servidor.listen(0, () => resolve({ servidor, pedidos, base: `http://127.0.0.1:${servidor.address().port}/v1` }));
  });
}
