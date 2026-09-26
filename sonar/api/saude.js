// GET /api/saude: diz se o servidor está de pé e se a pesquisa tem chave configurada.
// Não revela a chave, o modelo nem nenhuma outra configuração.

export default function handler(req, res) {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify({ ok: true, pesquisa_configurada: Boolean(process.env.XAI_API_KEY) }));
}
