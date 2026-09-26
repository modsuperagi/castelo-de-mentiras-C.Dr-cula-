// Limite de uso por endereço. Cada investigação custa chamadas pagas, então um mesmo
// endereço não pode disparar pesquisas sem parar. É um freio por instância do servidor
// (a memória não é compartilhada entre instâncias): suficiente para o MVP, não para escala.

const janelas = new Map();

export function enderecoDe(req) {
  const encaminhado = req.headers['x-forwarded-for'];
  if (typeof encaminhado === 'string' && encaminhado) return encaminhado.split(',')[0].trim();
  return req.headers['x-real-ip'] || req.socket?.remoteAddress || 'desconhecido';
}

export function consumir(endereco, env = process.env, agora = Date.now()) {
  const maximo = Number(env.SONAR_LIMITE_POR_JANELA) || 10;
  const janelaMs = (Number(env.SONAR_JANELA_MINUTOS) || 10) * 60_000;
  const recentes = (janelas.get(endereco) || []).filter((t) => agora - t < janelaMs);
  if (recentes.length >= maximo) {
    janelas.set(endereco, recentes);
    return { permitido: false, esperarSegundos: Math.ceil((janelaMs - (agora - recentes[0])) / 1000) };
  }
  recentes.push(agora);
  janelas.set(endereco, recentes);
  if (janelas.size > 5000) janelas.delete(janelas.keys().next().value);
  return { permitido: true };
}
