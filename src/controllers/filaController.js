const filaService = require('../services/filaService');

async function postFila(req, res, next) {
  try {
    const { nome, quantidade_pessoas } = req.body;
    const entrada = await filaService.entrarNaFila({ nome, quantidade_pessoas });
    return res.status(201).json(entrada);
  } catch (err) {
    next(err);
  }
}

async function getFila(req, res, next) {
  try {
    const fila = await filaService.listarFila();
    return res.status(200).json(fila);
  } catch (err) {
    next(err);
  }
}

async function getFilaById(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(400).json({ erro: 'ID inválido.' });
    }
    const entrada = await filaService.buscarPorId(id);
    return res.status(200).json(entrada);
  } catch (err) {
    next(err);
  }
}

async function putFilaStatus(req, res, next) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) {
      return res.status(400).json({ erro: 'ID inválido.' });
    }
    const { status, mesa_id } = req.body;
    const entrada = await filaService.atualizarStatus(id, { status, mesa_id });
    return res.status(200).json(entrada);
  } catch (err) {
    next(err);
  }
}

module.exports = { postFila, getFila, getFilaById, putFilaStatus };
