const { Router } = require('express');
const mesaController = require('../controllers/mesaController');

const router = Router();

router.get('/', mesaController.getMesas);

module.exports = router;
