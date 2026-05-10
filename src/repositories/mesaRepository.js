const { getDatabase } = require('../database');

async function findById(id, db = null) {
  const database = db || await getDatabase();
  return database.get('SELECT * FROM mesa WHERE id = ?', [id]);
}

async function setDisponivel(id, disponivel, db = null) {
  const database = db || await getDatabase();
  await database.run('UPDATE mesa SET disponivel = ? WHERE id = ?', [disponivel ? 1 : 0, id]);
}

module.exports = { findById, setDisponivel };
