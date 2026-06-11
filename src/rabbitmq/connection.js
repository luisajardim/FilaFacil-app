const amqp = require('amqplib');

const QUEUES = ['fila.criada.queue', 'fila.chamada.queue', 'fila.finalizada.queue'];

let connectionPromise;
let cachedConnection;

function getRabbitUrl() {
  return process.env.RABBITMQ_URL || 'amqp://localhost';
}

async function connect() {
  if (cachedConnection) {
    return cachedConnection;
  }

  if (!connectionPromise) {
    console.log(`[RABBITMQ] Conectando em ${getRabbitUrl()}...`);
    connectionPromise = amqp
      .connect(getRabbitUrl())
      .then((connection) => {
        cachedConnection = connection;
        connection.on('close', () => {
          console.log('[RABBITMQ] Conexão encerrada.');
          cachedConnection = null;
          connectionPromise = null;
        });
        connection.on('error', (err) => {
          console.error('[RABBITMQ] Erro na conexão:', err.message);
        });
        return connection;
      })
      .catch((err) => {
        connectionPromise = null;
        throw err;
      });
  }

  return connectionPromise;
}

async function createChannel() {
  const connection = await connect();
  const channel = await connection.createChannel();

  for (const queue of QUEUES) {
    await channel.assertQueue(queue, { durable: true });
  }

  return channel;
}

async function closeConnection() {
  if (cachedConnection) {
    await cachedConnection.close();
    cachedConnection = null;
    connectionPromise = null;
  }
}

module.exports = { connect, createChannel, closeConnection, QUEUES };
