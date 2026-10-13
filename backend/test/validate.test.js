const test = require('node:test');
const assert = require('node:assert');
const { parseScore } = require('../src/validate');

test('accepts a valid score', () => {
  const r = parseScore({ name: 'Roudayna', score: 1200, level: 3, lines: 14 });
  assert.deepStrictEqual(r.value, { name: 'Roudayna', score: 1200, level: 3, lines: 14 });
});
test('rejects bad names', () => {
  assert.ok(parseScore({ name: "x'; DROP TABLE scores;--", score: 1, level: 1, lines: 1 }).error);
  assert.ok(parseScore({ name: '', score: 1, level: 1, lines: 1 }).error);
});
test('rejects non-integer or out-of-range numbers', () => {
  assert.ok(parseScore({ name: 'a', score: -1, level: 1, lines: 1 }).error);
  assert.ok(parseScore({ name: 'a', score: '10', level: 1, lines: 1 }).error);
  assert.ok(parseScore({ name: 'a', score: 1.5, level: 1, lines: 1 }).error);
});
