const { createChannel } = require('./connection');

const EVENT_TO_QUEUE = {
  'fila.criada': 'fila.criada.queue',
  'fila.chamada': 'fila.chamada.queue',
  'fila.finalizada': 'fila.finalizada.queue',
};

async function publishEvent(eventName, payload) {
  const queue = EVENT_TO_QUEUE[eventName];
  if (!queue) {
    console.warn(`[PUBLISHER] Evento desconhecido ignorado: ${eventName}`);
    return false;
  }

  try {
    const channel = await createChannel();
    const message = Buffer.from(JSON.stringify({ event: eventName, payload }));
    channel.sendToQueue(queue, message, {
      contentType: 'application/json',
      persistent: true,
      timestamp: Date.now(),
    });
    console.log(`[PUBLISHER] Evento ${eventName} publicado em ${queue}.`);
    await channel.close();
    return true;
  } catch (err) {
    console.error(`[PUBLISHER] Falha ao publicar ${eventName}:`, err.message);
    return false;
  }
}

async function assertQueues(channel) {
  for (const queue of QUEUES) {
    await channel.assertQueue(queue, { durable: true });
  }
}

module.exports = { publishEvent, assertQueues };
