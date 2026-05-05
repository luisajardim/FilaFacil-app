const { getPool } = require('../database');

async function findById(id) {
  const [rows] = await getPool().execute(
    'SELECT * FROM mesa WHERE id = ?',
    [id]
  );
  return rows[0] || null;
}

async function setDisponivel(id, disponivel, conn = null) {
  const db = conn || getPool();
  await db.execute(
    'UPDATE mesa SET disponivel = ? WHERE id = ?',
    [disponivel, id]
  );
}

module.exports = { findById, setDisponivel };
