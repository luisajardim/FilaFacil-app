// Middleware de tratamento de erros centralizado
function errorHandler(err, req, res, next) { // eslint-disable-line no-unused-vars
  const statusCode = err.statusCode || 500;
  const mensagem = err.message || 'Erro interno do servidor.';

  if (statusCode === 500) {
    console.error('[Erro interno]', err);
  }

  return res.status(statusCode).json({ erro: mensagem });
}

module.exports = errorHandler;
