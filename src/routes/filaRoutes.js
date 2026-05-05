const { Router } = require('express');
const filaController = require('../controllers/filaController');

const router = Router();

// POST /fila — Criar entrada na fila
router.post('/', filaController.postFila);

// GET /fila — Listar fila
router.get('/', filaController.getFila);

// GET /fila/:id — Buscar por ID
router.get('/:id', filaController.getFilaById);

// PUT /fila/:id/status — Atualizar status
router.put('/:id/status', filaController.putFilaStatus);

module.exports = router;
