const mysql = require('mysql2/promise');

let pool;

function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 3306,
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'filafacil',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
    });
  }
  return pool;
}

async function initDatabase() {
  const conn = await getPool().getConnection();
  try {
    // Criar tabelas
    await conn.execute(`
      CREATE TABLE IF NOT EXISTS cliente (
        id INT AUTO_INCREMENT PRIMARY KEY,
        nome VARCHAR(255) NOT NULL,
        criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await conn.execute(`
      CREATE TABLE IF NOT EXISTS mesa (
        id INT AUTO_INCREMENT PRIMARY KEY,
        capacidade INT NOT NULL,
        disponivel BOOLEAN NOT NULL DEFAULT TRUE
      )
    `);

    await conn.execute(`
      CREATE TABLE IF NOT EXISTS fila (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cliente_id INT NOT NULL,
        quantidade_pessoas INT NOT NULL,
        status ENUM('AGUARDANDO', 'CHAMADO', 'ATENDIDO') NOT NULL DEFAULT 'AGUARDANDO',
        mesa_id INT NULL,
        criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cliente_id) REFERENCES cliente(id),
        FOREIGN KEY (mesa_id) REFERENCES mesa(id)
      )
    `);

    // Seed: garantir as 4 mesas
    await seedMesas(conn);

    console.log('Banco de dados inicializado com sucesso.');
  } finally {
    conn.release();
  }
}

async function seedMesas(conn) {
  const mesas = [
    { id: 1, capacidade: 2 },
    { id: 2, capacidade: 4 },
    { id: 3, capacidade: 4 },
    { id: 4, capacidade: 8 },
  ];

  for (const mesa of mesas) {
    // Insere apenas se não existir
    await conn.execute(
      `INSERT INTO mesa (id, capacidade, disponivel)
       VALUES (?, ?, TRUE)
       ON DUPLICATE KEY UPDATE capacidade = VALUES(capacidade)`,
      [mesa.id, mesa.capacidade]
    );
  }

  console.log('Seed de mesas concluído.');
}

module.exports = { getPool, initDatabase };
