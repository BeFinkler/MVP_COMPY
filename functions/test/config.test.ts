import assert from 'node:assert/strict';
import test from 'node:test';

import { administrativeFunctionsRegion } from '../src/config.js';
import {
  getAdminUserAuthDetails,
  getAdminUsersAuthStatus,
  setUserSuspension,
} from '../src/index.js';

test('Functions administrativas usam a região aprovada', () => {
  assert.equal(administrativeFunctionsRegion, 'southamerica-east1');
});

test('as três Callables exportam a região aprovada no contrato de deploy', () => {
  for (const callable of [getAdminUserAuthDetails, getAdminUsersAuthStatus, setUserSuspension]) {
    assert.deepEqual(callable.__endpoint.region, ['southamerica-east1']);
  }
});
