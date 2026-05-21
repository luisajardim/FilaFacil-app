const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3');
const { open } = require('sqlite');
const { Pool } = require('pg');

let databasePromise;
let postgresPool;

function isPostgres() {
  return (process.env.DB_CLIENT || 'sqlite').toLowerCase() === 'postgres';
}

function getDatabasePath() {
  return path.resolve(process.cwd(), process.env.DB_PATH || path.join('data', 'filafacil.sqlite'));
}

function createSqliteWrapper(db) {
  return {
    exec: (sql) => db.exec(sql),
    run: (sql, params = []) => db.run(sql, params),
    get: (sql, params = []) => db.get(sql, params),
    all: (sql, params = []) => db.all(sql, params),
    close: () => db.close(),
  };
}

function createPostgresWrapper(pool) {
  const toPostgresSql = (sql) => {
    let index = 0;
    return sql.replace(/\?/g, () => `$${++index}`);
  };

  return {
    exec: async (sql) => {
      await pool.query(sql);
    },
    run: async (sql, params = []) => {
      const normalizedSql = /\binsert\b/i.test(sql) && !/\breturning\b/i.test(sql)
        ? `${sql} RETURNING id`
        : sql;
      const result = await pool.query(toPostgresSql(normalizedSql), params);
      return {
        lastID: result.rows[0]?.id ?? null,
        changes: result.rowCount,
      };
    },
    get: async (sql, params = []) => {
      const result = await pool.query(toPostgresSql(sql), params);
      return result.rows[0];
    },
    all: async (sql, params = []) => {
      const result = await pool.query(toPostgresSql(sql), params);
      return result.rows;
    },
    close: () => pool.end(),
  };
}

async function getDatabase() {
  if (!databasePromise) {
    if (isPostgres()) {
      const connectionString = process.env.DATABASE_URL;
      postgresPool = new Pool(
        connectionString
          ? { connectionString }
          : {
              host: process.env.PGHOST || 'localhost',
              port: parseInt(process.env.PGPORT || '5432', 10),
              database: process.env.PGDATABASE || 'filafacil',
              user: process.env.PGUSER || 'postgres',
              password: process.env.PGPASSWORD || 'postgres',
            }
      );
      databasePromise = Promise.resolve(createPostgresWrapper(postgresPool));
    } else {
      const dbPath = getDatabasePath();
      fs.mkdirSync(path.dirname(dbPath), { recursive: true });
      databasePromise = open({ filename: dbPath, driver: sqlite3.Database }).then((db) => {
        db.exec('PRAGMA foreign_keys = ON');
        return createSqliteWrapper(db);
      });
    }
  }

  return databasePromise;
}

async function initDatabase() {
  const db = await getDatabase();

  if (isPostgres()) {
    await db.exec(`
      CREATE TABLE IF NOT EXISTS cliente (
        id SERIAL PRIMARY KEY,
        nome TEXT NOT NULL UNIQUE,
        criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);

    await db.exec(`
      CREATE TABLE IF NOT EXISTS mesa (
        id INTEGER PRIMARY KEY,
        capacidade INTEGER NOT NULL,
        disponivel BOOLEAN NOT NULL DEFAULT TRUE
      )
    `);

    await db.exec(`
      CREATE TABLE IF NOT EXISTS fila (
        id SERIAL PRIMARY KEY,
        cliente_id INTEGER NOT NULL REFERENCES cliente(id),
        quantidade_pessoas INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'AGUARDANDO',
        mesa_id INTEGER NULL REFERENCES mesa(id),
        criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        CHECK (status IN ('AGUARDANDO', 'CHAMADO', 'ATENDIDO'))
      )
    `);
  } else {
    await db.exec(`
      CREATE TABLE IF NOT EXISTS cliente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE,
        criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
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
        criado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cliente_id) REFERENCES cliente(id),
        FOREIGN KEY (mesa_id) REFERENCES mesa(id),
        CHECK (status IN ('AGUARDANDO', 'CHAMADO', 'ATENDIDO'))
      )
    `);
  }

  await seedMesas(db);
  console.log(`[DATABASE] Banco inicializado com sucesso usando ${isPostgres() ? 'PostgreSQL' : 'SQLite'}.`);
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
      `INSERT INTO mesa (id, capacidade, disponivel) VALUES (?, ?, ?)
       ON CONFLICT(id) DO UPDATE SET capacidade = excluded.capacidade, disponivel = excluded.disponivel`,
      [mesa.id, mesa.capacidade, isPostgres() ? true : 1]
    );
  }

  console.log('[DATABASE] Seed de mesas concluído.');
}

module.exports = { getDatabase, initDatabase };

