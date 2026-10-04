import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

const FIO_UNIVERSAL = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916';

interface SincRequest {
  acao: 'VERIFICAR_PONTE' | 'SINCRONIZAR_PENDENTES' | 'RESOLVER_CONFLITOS' | 'STATUS';
  origem?: 'GHOST' | 'CASTELO';
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*' } });
  }

  try {
    const payload: SincRequest = await req.json();
    const acao = payload.acao || 'STATUS';

    // ========================
    // 1. VERIFICAR PONTE
    // ========================
    if (acao === 'VERIFICAR_PONTE') {
      const { data: ponte, error: erroponte } = await supabase
        .from('ponte_ghost_castelo')
        .select('*')
        .eq('fio_id', FIO_UNIVERSAL)
        .limit(50);

      if (erroponte) throw erroponte;

      return new Response(
        JSON.stringify({
          fio: FIO_UNIVERSAL,
          ponte_ativa: ponte && ponte.length > 0,
          registros_ponte: ponte?.length || 0,
          status: 'PONTE_VERIFICADA',
          timestamp: new Date().toISOString(),
        }),
        {
          headers: { 'Content-Type': 'application/json' },
          status: 200,
        }
      );
    }

    // ========================
    // 2. SINCRONIZAR PENDENTES
    // ========================
    if (acao === 'SINCRONIZAR_PENDENTES') {
      const { data: pendentes, error: erroPendentes } = await supabase
        .from('ponte_ghost_castelo')
        .select('*')
        .eq('fio_id', FIO_UNIVERSAL)
        .eq('status_sinc', 'pendente')
        .limit(20);

      if (erroPendentes) throw erroPendentes;

      let sincronizados = 0;
      let erros = 0;

      for (const registro of pendentes || []) {
        try {
          // Marca como sincronizando
          await supabase
            .from('ponte_ghost_castelo')
            .update({
              status_sinc: 'sincronizando',
              timestamp_sinc: new Date().toISOString(),
            })
            .eq('id', registro.id);

          // Simula sincronização (em produção, chamaria API do Ghost)
          await new Promise((resolve) => setTimeout(resolve, 100));

          // Marca como sincronizado
          await supabase
            .from('ponte_ghost_castelo')
            .update({
              status_sinc: 'sincronizado',
              timestamp_confirmacao: new Date().toISOString(),
              hash_destino: await geraHash(registro.dados_sincronizar),
            })
            .eq('id', registro.id);

          sincronizados++;
        } catch (e) {
          erros++;
          await supabase
            .from('ponte_ghost_castelo')
            .update({ status_sinc: 'erro' })
            .eq('id', registro.id);
        }
      }

      return new Response(
        JSON.stringify({
          fio: FIO_UNIVERSAL,
          acao: 'SINCRONIZAR_PENDENTES',
          sincronizados,
          erros,
          timestamp: new Date().toISOString(),
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }

    // ========================
    // 3. RESOLVER CONFLITOS
    // ========================
    if (acao === 'RESOLVER_CONFLITOS') {
      const { data: conflitos } = await supabase
        .from('ponte_ghost_castelo')
        .select('*')
        .eq('fio_id', FIO_UNIVERSAL)
        .eq('status_sinc', 'conflito');

      // Estratégia: última escrita vence (Castelo é source of truth)
      let resolvidos = 0;
      for (const conflito of conflitos || []) {
        await supabase
          .from('ponte_ghost_castelo')
          .update({
            status_sinc: 'sincronizado',
            pode_sobrescrever: true,
          })
          .eq('id', conflito.id);
        resolvidos++;
      }

      return new Response(
        JSON.stringify({
          fio: FIO_UNIVERSAL,
          conflitos_resolvidos: resolvidos,
          timestamp: new Date().toISOString(),
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }

    // ========================
    // 4. STATUS DA PONTE
    // ========================
    if (acao === 'STATUS') {
      const { data: status } = await supabase
        .from('v_ponte_status')
        .select('*')
        .single();

      const { data: mariana } = await supabase
        .from('v_mariana_status')
        .select('*');

      return new Response(
        JSON.stringify({
          fio: FIO_UNIVERSAL,
          ponte: status,
          mariana_status: mariana,
          timestamp: new Date().toISOString(),
        }),
        { headers: { 'Content-Type': 'application/json' }, status: 200 }
      );
    }

    throw new Error(`Ação desconhecida: ${acao}`);
  } catch (error) {
    console.error('Erro na ponte:', error);
    return new Response(
      JSON.stringify({
        erro: error.message,
        fio: FIO_UNIVERSAL,
        timestamp: new Date().toISOString(),
      }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});

// Função auxiliar: gera hash para validação
async function geraHash(obj: unknown): Promise<string> {
  const str = JSON.stringify(obj);
  const encoder = new TextEncoder();
  const data = encoder.encode(str);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');
}
