const { getPool } = require('../database');

async function findByNome(nome) {
  const [rows] = await getPool().execute(
    'SELECT * FROM cliente WHERE nome = ? LIMIT 1',
    [nome]
  );
  return rows[0] || null;
}

async function create(nome) {
  const [result] = await getPool().execute(
    'INSERT INTO cliente (nome, criado_em) VALUES (?, NOW())',
    [nome]
  );
  return { id: result.insertId, nome };
}

async function findOrCreate(nome) {
  let cliente = await findByNome(nome);
  if (!cliente) {
    cliente = await create(nome);
  }
  return cliente;
}

module.exports = { findByNome, create, findOrCreate };
