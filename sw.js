// Service worker do Espelho Espelho Evo.
// Páginas: rede primeiro, cache como reserva, para o app abrir mesmo com internet ruim sem servir versão velha quando há rede.
// Dados do Castelo (Supabase) nunca passam por cache: o espelho mostra sempre o estado vivo.
const VERSAO = 'espelho-evo-v11';
const CASCA = [
  '/',
  '/nucleos.html',
  '/manifest.webmanifest',
  '/icons/icone-192.png',
  '/icons/icone-512.png',
  '/icons/icone.svg'
];

self.addEventListener('install', (evento) => {
  evento.waitUntil(caches.open(VERSAO).then((cache) => cache.addAll(CASCA)));
  self.skipWaiting();
});

self.addEventListener('activate', (evento) => {
  evento.waitUntil(
    caches.keys().then((chaves) => Promise.all(chaves.filter((c) => c !== VERSAO).map((c) => caches.delete(c))))
  );
  self.clients.claim();
});

self.addEventListener('fetch', (evento) => {
  const pedido = evento.request;
  if (pedido.method !== 'GET') return;
  const url = new URL(pedido.url);
  if (url.origin !== self.location.origin) return;

  evento.respondWith(
    fetch(pedido)
      .then((resposta) => {
        if (resposta.ok) {
          const copia = resposta.clone();
          caches.open(VERSAO).then((cache) => cache.put(pedido, copia));
        }
        return resposta;
      })
      .catch(() => caches.match(pedido).then((guardada) => guardada || caches.match('/')))
  );
});
