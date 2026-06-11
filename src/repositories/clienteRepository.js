const { getDatabase } = require('../database');

async function findByNome(nome, db = null) {
  const database = db || await getDatabase();
  return database.get('SELECT * FROM cliente WHERE nome = ? LIMIT 1', [nome]);
}

async function create(nome, db = null) {
  const database = db || await getDatabase();
  const criadoEm = new Date().toISOString();
  await database.run('INSERT INTO cliente (nome, criado_em) VALUES (?, ?)', [nome, criadoEm]);
  return findByNome(nome, database);
}

async function findOrCreate(nome, db = null) {
  let cliente = await findByNome(nome, db);
  if (!cliente) {
    cliente = await create(nome, db);
  }
  return cliente;
}

module.exports = { findByNome, create, findOrCreate };
