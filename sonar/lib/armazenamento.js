// Adaptador de armazenamento. O destino definitivo dos resultados ainda não foi escolhido,
// então o SONAR fala só com esta interface: salvar(registro) → { salvo, destino }.
// Trocar o destino é trocar o driver, sem mexer no resto do produto.
//
// SONAR_ARMAZENAMENTO=nenhum   (padrão) não guarda nada.
// SONAR_ARMAZENAMENTO=memoria  guarda na memória do processo (só para desenvolvimento local).
// SONAR_ARMAZENAMENTO=webhook  envia o registro em JSON para SONAR_ARMAZENAMENTO_URL,
//                              com Authorization: Bearer SONAR_ARMAZENAMENTO_TOKEN se houver.

const memoria = [];

const drivers = {
  nenhum: async () => ({ salvo: false, destino: 'nenhum' }),

  memoria: async (registro) => {
    memoria.push(registro);
    if (memoria.length > 200) memoria.shift();
    return { salvo: true, destino: 'memoria' };
  },

  webhook: async (registro, env) => {
    if (!env.SONAR_ARMAZENAMENTO_URL) return { salvo: false, destino: 'webhook', erro: 'sem URL' };
    const headers = { 'Content-Type': 'application/json' };
    if (env.SONAR_ARMAZENAMENTO_TOKEN) headers.Authorization = `Bearer ${env.SONAR_ARMAZENAMENTO_TOKEN}`;
    const resposta = await fetch(env.SONAR_ARMAZENAMENTO_URL, {
      method: 'POST',
      headers,
      body: JSON.stringify(registro),
      signal: AbortSignal.timeout(4000),
    });
    return { salvo: resposta.ok, destino: 'webhook', erro: resposta.ok ? undefined : `HTTP ${resposta.status}` };
  },
};

export async function salvar(registro, env = process.env) {
  const driver = drivers[env.SONAR_ARMAZENAMENTO || 'nenhum'] || drivers.nenhum;
  try {
    return await driver(registro, env);
  } catch (erro) {
    // Falha ao guardar nunca derruba a investigação já concluída.
    return { salvo: false, destino: env.SONAR_ARMAZENAMENTO, erro: erro.message };
  }
}

export function lerMemoria() {
  return [...memoria];
}
