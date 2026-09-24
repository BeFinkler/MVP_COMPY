import assert from 'node:assert/strict';
import test from 'node:test';

import { administrativeFunctionsRegion } from '../src/config.js';

test('Functions administrativas usam a região aprovada', () => {
  assert.equal(administrativeFunctionsRegion, 'southamerica-east1');
});
