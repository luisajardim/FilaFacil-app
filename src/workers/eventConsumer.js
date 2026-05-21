require('dotenv').config();

const { createChannel, QUEUES } = require('../rabbitmq/connection');

function formatMessage(eventName, payload) {
  if (eventName === 'fila.criada') {
    return `[FILA_CRIADA]\nCliente ${payload.cliente} entrou na fila com grupo de ${payload.quantidade_pessoas} pessoas`;
  }

  if (eventName === 'fila.chamada') {
    return `[FILA_CHAMADA]\nCliente ${payload.cliente} foi chamado para mesa ${payload.mesaId}`;
  }

  if (eventName === 'fila.finalizada') {
    return `[FILA_FINALIZADA]\nAtendimento finalizado para cliente ${payload.cliente}`;
  }

  return `[CONSUMER] Evento não mapeado: ${eventName}`;
}

async function start() {
  try {
    const channel = await createChannel();
    await channel.prefetch(10);

    console.log('[CONSUMER] Worker iniciado. Aguardando mensagens...');

    for (const queue of QUEUES) {
      await channel.consume(queue, async (msg) => {
        if (!msg) {
          return;
        }

        try {
          const body = JSON.parse(msg.content.toString('utf8'));
          const eventName = body.event || queue.replace('.queue', '');
          console.log(formatMessage(eventName, body.payload));
          channel.ack(msg);
        } catch (err) {
          console.error('[CONSUMER] Falha ao processar mensagem:', err.message);
          channel.ack(msg);
        }
      }, { noAck: false });
    }
  } catch (err) {
    console.error('[CONSUMER] Não foi possível iniciar o worker:', err.message);
    setTimeout(start, 5000);
  }
}

start();
