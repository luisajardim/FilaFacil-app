const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3');
const { open } = require('sqlite');

let databasePromise;

function getDatabasePath() {
  return path.resolve(process.cwd(), process.env.DB_PATH || path.join('data', 'filafacil.sqlite'));
}

async function getDatabase() {
  if (!databasePromise) {
    const dbPath = getDatabasePath();
    fs.mkdirSync(path.dirname(dbPath), { recursive: true });
    databasePromise = open({ filename: dbPath, driver: sqlite3.Database });
  }
  const db = await databasePromise;
  await db.exec('PRAGMA foreign_keys = ON');
  return db;
}

async function initDatabase() {
  const db = await getDatabase();

  await db.exec(`
    CREATE TABLE IF NOT EXISTS cliente (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL UNIQUE,
      criado_em TEXT NOT NULL DEFAULT (datetime('now'))
    )
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS mesa (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      capacidade INTEGER NOT NULL,
      disponivel INTEGER NOT NULL DEFAULT 1
    )
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS fila (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente_id INTEGER NOT NULL,
      quantidade_pessoas INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'AGUARDANDO',
      mesa_id INTEGER NULL,
      criado_em TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (cliente_id) REFERENCES cliente(id),
      FOREIGN KEY (mesa_id) REFERENCES mesa(id),
      CHECK (status IN ('AGUARDANDO', 'CHAMADO', 'ATENDIDO'))
    )
  `);

  await seedMesas(db);
  console.log('Banco de dados inicializado com sucesso.');
}

async function seedMesas(db) {
  const mesas = [
    { id: 1, capacidade: 2 },
    { id: 2, capacidade: 4 },
    { id: 3, capacidade: 4 },
    { id: 4, capacidade: 8 },
  ];

  for (const mesa of mesas) {
    await db.run(
      `INSERT INTO mesa (id, capacidade, disponivel) VALUES (?, ?, 1)
       ON CONFLICT(id) DO UPDATE SET capacidade = excluded.capacidade`,
      [mesa.id, mesa.capacidade]
    );
  }
  console.log('Seed de mesas concluído.');
}

module.exports = { getDatabase, initDatabase };
