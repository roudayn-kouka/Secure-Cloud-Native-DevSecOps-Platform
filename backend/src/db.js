const fs = require('fs');
const mysql = require('mysql2/promise');

function buildSsl() {
  if (process.env.DB_SSL !== 'true') return undefined;
  const caPath = process.env.DB_SSL_CA;
  // RDS enforces TLS (require_secure_transport); verify the server certificate with the RDS CA bundle.
  return caPath ? { ca: fs.readFileSync(caPath), minVersion: 'TLSv1.2' } : { minVersion: 'TLSv1.2' };
}

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'tetris',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'tetris',
  waitForConnections: true,
  connectionLimit: 10,
  connectTimeout: 10000,
  ssl: buildSsl(),
});

async function init() {
  await pool.query(`CREATE TABLE IF NOT EXISTS scores (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    score INT UNSIGNED NOT NULL,
    level INT UNSIGNED NOT NULL,
    line_count INT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_score (score DESC)
  ) ENGINE=InnoDB`);
}

module.exports = { pool, init };
