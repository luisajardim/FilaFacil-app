require('dotenv').config();
const express = require('express');
const { initDatabase } = require('./database');
const filaRoutes = require('./routes/filaRoutes');
const mesaRoutes = require('./routes/mesaRoutes');
const errorHandler = require('./middlewares/errorHandler');

const app = express();

app.use(express.json());

// Permite CORS para desenvolvimento local (Flutter Web / Postman)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(200);
  next();
});

app.use('/fila', filaRoutes);
app.use('/mesa', mesaRoutes);

app.get('/', (req, res) => {
  res.json({
    sistema: 'FilaFácil',
    versao: '1.0.0',
    arquitetura: ['REST', 'EDA', 'MOM'],
    endpoints: [
      'POST   /fila',
      'GET    /fila',
      'GET    /fila/:id',
      'PUT    /fila/:id/status',
      'GET    /mesa',
      'GET    /',
    ],
  });
});

app.use(errorHandler);

const PORT = process.env.PORT || 3000;

async function start() {
  try {
    await initDatabase();
    app.listen(PORT, () => {
      console.log(`[API] FilaFácil rodando na porta ${PORT}`);
    });
  } catch (err) {
    console.error('[API] Erro ao iniciar a aplicação:', err);
    process.exit(1);
  }
}

start();

module.exports = app;
