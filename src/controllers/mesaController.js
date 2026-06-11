const mesaRepository = require('../repositories/mesaRepository');

async function getMesas(req, res, next) {
  try {
    const mesas = await mesaRepository.findAll();
    return res.status(200).json(mesas);
  } catch (err) {
    next(err);
  }
}

module.exports = { getMesas };
