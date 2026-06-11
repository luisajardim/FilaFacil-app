const { getDatabase } = require('../database');

async function findAll(db = null) {
  const database = db || await getDatabase();
  const rows = await database.all('SELECT * FROM mesa ORDER BY id ASC');
  return rows.map((row) => ({
    id: row.id,
    capacidade: row.capacidade,
    disponivel: row.disponivel === 1 || row.disponivel === true,
  }));
}

async function findById(id, db = null) {
  const database = db || await getDatabase();
  return database.get('SELECT * FROM mesa WHERE id = ?', [id]);
}

async function setDisponivel(id, disponivel, db = null) {
  const database = db || await getDatabase();
  await database.run('UPDATE mesa SET disponivel = ? WHERE id = ?', [disponivel ? 1 : 0, id]);
}

module.exports = { findAll, findById, setDisponivel };
