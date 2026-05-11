require('dotenv').config();
const express = require('express');
const { initDatabase } = require('./database');
const filaRoutes = require('./routes/filaRoutes');
const errorHandler = require('./middlewares/errorHandler');

const app = express();

app.use(express.json());

app.use('/fila', filaRoutes);

app.get('/', (req, res) => {
  res.json({
    sistema: 'FilaFácil',
    versao: '1.0.0',
    endpoints: [
      'POST   /fila',
      'GET    /fila',
      'GET    /fila/:id',
      'PUT    /fila/:id/status',
    ],
  });
});

app.use(errorHandler);

const PORT = process.env.PORT || 3000;

async function start() {
  try {
    await initDatabase();
    app.listen(PORT, () => {
      console.log(`FilaFácil rodando na porta ${PORT}`);
    });
  } catch (err) {
    console.error('Erro ao iniciar a aplicação:', err);
    process.exit(1);
  }
}

start();

module.exports = app;
