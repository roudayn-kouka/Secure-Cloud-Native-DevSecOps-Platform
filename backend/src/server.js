const express = require('express');
const helmet = require('helmet');
const client = require('prom-client');
const { pool, init } = require('./db');
const { parseScore } = require('./validate');

const app = express();
app.disable('x-powered-by');
app.use(helmet());
app.use(express.json({ limit: '2kb' }));

// ---- Prometheus metrics (scraped through the ServiceMonitor in the Helm chart) ----
client.collectDefaultMetrics();
const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.005, 0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5],
});
const scoresSubmitted = new client.Counter({
  name: 'tetris_scores_submitted_total',
  help: 'Number of scores stored',
});

app.use((req, res, next) => {
  const end = httpDuration.startTimer();
  res.on('finish', () => {
    const route = req.route ? req.baseUrl + req.route.path : 'unmatched';
    end({ method: req.method, route, status: res.statusCode });
  });
  next();
});

// ---- Probes ----
app.get('/healthz', (_req, res) => res.json({ status: 'ok' })); // liveness: process is up
app.get('/readyz', async (_req, res) => { // readiness: database reachable
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ready' });
  } catch (e) {
    res.status(503).json({ status: 'database unavailable' });
  }
});
app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// ---- API ----
app.get('/api/scores', async (req, res) => {
  const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 100);
  try {
    const [rows] = await pool.query(
      'SELECT name, score, level, line_count AS `lines`, created_at FROM scores ORDER BY score DESC LIMIT ?', [limit]);
    res.json(rows);
  } catch (e) {
    console.error('list scores failed', e.code);
    res.status(500).json({ error: 'internal error' });
  }
});

app.post('/api/scores', async (req, res) => {
  const { value, error } = parseScore(req.body);
  if (error) return res.status(400).json({ error });
  try {
    // parameterised query: no SQL injection
    await pool.query('INSERT INTO scores (name, score, level, line_count) VALUES (?, ?, ?, ?)',
      [value.name, value.score, value.level, value.lines]);
    scoresSubmitted.inc();
    res.status(201).json({ status: 'created' });
  } catch (e) {
    console.error('insert score failed', e.code);
    res.status(500).json({ error: 'internal error' });
  }
});

const port = Number(process.env.PORT || 3000);

async function start() {
  // Retry so the pod survives a slow database start instead of crash-looping immediately.
  for (let attempt = 1; ; attempt++) {
    try { await init(); break; } catch (e) {
      console.error(`database init failed (attempt ${attempt}): ${e.code || e.message}`);
      if (attempt >= 10) process.exit(1);
      await new Promise((r) => setTimeout(r, 3000));
    }
  }
  const server = app.listen(port, () => console.log(`leaderboard api listening on ${port}`));
  process.on('SIGTERM', () => server.close(() => pool.end().then(() => process.exit(0))));
}

if (require.main === module) start();
module.exports = app;
