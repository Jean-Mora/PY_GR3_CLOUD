require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = 3000;

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 5432,
});

app.use(express.static(__dirname));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Endpoint optimizado trayendo también al Profesor
app.get('/api/v1/estudiantes/notas', async (req, res) => {
  const start = Date.now();
  try {
    const queryText = `
      SELECT e.id, e.nombre, m.nombre AS materia, p.nombre AS profesor, e.nota 
      FROM estudiantes e
      INNER JOIN materias m ON e.materia_id = m.id
      LEFT JOIN profesores p ON m.profesor_id = p.id
      ORDER BY e.id ASC;
    `;
    const result = await pool.query(queryText);
    res.json({
      success: true,
      latency_ms: Date.now() - start,
      data: result.rows
    });
  } catch (err) {
    res.status(500).json({ success: false, error: 'Error en el clúster relacional de datos' });
  }
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP', timestamp: new Date() });
});

app.listen(port, () => {
  console.log(`Control Escolar corriendo en el puerto ${port}`);
});
