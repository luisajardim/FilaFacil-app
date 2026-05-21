const { getDatabase } = require('../database');

const SELECT_FILA = `
  SELECT
    f.id,
    f.quantidade_pessoas,
    f.status,
    f.mesa_id,
    f.criado_em,
    c.id   AS cliente_id,
    c.nome AS cliente_nome,
    m.capacidade AS mesa_capacidade,
    m.disponivel AS mesa_disponivel
  FROM fila f
  JOIN cliente c ON c.id = f.cliente_id
  LEFT JOIN mesa m ON m.id = f.mesa_id
`;

function formatRow(row) {
  if (!row) return null;
  return {
    id: row.id,
    cliente: {
      id: row.cliente_id,
      nome: row.cliente_nome,
    },
    quantidade_pessoas: row.quantidade_pessoas,
    status: row.status,
    mesa: row.mesa_id
      ? {
          id: row.mesa_id,
          capacidade: row.mesa_capacidade,
          disponivel: !!row.mesa_disponivel,
        }
      : null,
    criado_em: row.criado_em,
  };
}

async function findAll(db = null) {
  const database = db || await getDatabase();
  const rows = await database.all(`${SELECT_FILA} ORDER BY f.criado_em ASC`);
  return rows.map(formatRow);
}

async function findById(id, db = null) {
  const database = db || await getDatabase();
  const row = await database.get(`${SELECT_FILA} WHERE f.id = ?`, [id]);
  return formatRow(row || null);
}

async function create({ cliente_id, quantidade_pessoas }, db = null) {
  const database = db || await getDatabase();
  const criadoEm = new Date().toISOString();
  const result = await database.run(
    `INSERT INTO fila (cliente_id, quantidade_pessoas, status, mesa_id, criado_em)
     VALUES (?, ?, 'AGUARDANDO', NULL, ?)`,
    [cliente_id, quantidade_pessoas, criadoEm]
  );

  const filaId = result?.lastID;
  if (!filaId) {
    const fallback = await database.get(
      'SELECT id FROM fila WHERE cliente_id = ? AND quantidade_pessoas = ? ORDER BY id DESC LIMIT 1',
      [cliente_id, quantidade_pessoas]
    );
    return findById(fallback.id, database);
  }

  return findById(filaId, database);
}

async function updateStatus(id, { status, mesa_id }, db = null) {
  const database = db || await getDatabase();

  if (mesa_id !== undefined) {
    await database.run('UPDATE fila SET status = ?, mesa_id = ? WHERE id = ?', [status, mesa_id, id]);
  } else {
    await database.run('UPDATE fila SET status = ? WHERE id = ?', [status, id]);
  }
}

module.exports = { findAll, findById, create, updateStatus };
