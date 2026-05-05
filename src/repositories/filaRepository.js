const { getPool } = require('../database');

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

async function findAll() {
  const [rows] = await getPool().execute(
    `${SELECT_FILA} ORDER BY f.criado_em ASC`
  );
  return rows.map(formatRow);
}

async function findById(id) {
  const [rows] = await getPool().execute(
    `${SELECT_FILA} WHERE f.id = ?`,
    [id]
  );
  return formatRow(rows[0] || null);
}

async function create({ cliente_id, quantidade_pessoas }) {
  const [result] = await getPool().execute(
    `INSERT INTO fila (cliente_id, quantidade_pessoas, status, mesa_id, criado_em)
     VALUES (?, ?, 'AGUARDANDO', NULL, NOW())`,
    [cliente_id, quantidade_pessoas]
  );
  return findById(result.insertId);
}

async function updateStatus(id, { status, mesa_id }, conn = null) {
  const db = conn || getPool();

  if (mesa_id !== undefined) {
    await db.execute(
      'UPDATE fila SET status = ?, mesa_id = ? WHERE id = ?',
      [status, mesa_id, id]
    );
  } else {
    await db.execute(
      'UPDATE fila SET status = ? WHERE id = ?',
      [status, id]
    );
  }
}

module.exports = { findAll, findById, create, updateStatus };
