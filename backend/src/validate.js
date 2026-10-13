// Input validation kept separate so it can be unit-tested without a database.
function parseScore(body) {
  if (!body || typeof body !== 'object') return { error: 'invalid body' };
  const name = typeof body.name === 'string' ? body.name.trim() : '';
  if (!/^[\p{L}\p{N} _.-]{1,32}$/u.test(name)) return { error: 'name must be 1-32 chars (letters, digits, space, _ . -)' };
  const ints = {};
  for (const [key, max] of [['score', 100000000], ['level', 1000], ['lines', 100000]]) {
    const v = body[key];
    if (!Number.isInteger(v) || v < 0 || v > max) return { error: `${key} must be an integer between 0 and ${max}` };
    ints[key] = v;
  }
  return { value: { name, ...ints } };
}

module.exports = { parseScore };
