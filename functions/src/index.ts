import { setGlobalOptions } from 'firebase-functions/v2';

import { administrativeFunctionsRegion } from './config.js';

// As Callables serão adicionadas nos tickets 09 e 14. Definir a região aqui
// evita que uma Function administrativa futura seja criada fora de São Paulo.
setGlobalOptions({ region: administrativeFunctionsRegion });

export { administrativeFunctionsRegion } from './config.js';
export { getAdminUserAuthDetails, getAdminUsersAuthStatus } from './admin_auth_read.js';
export { setUserSuspension } from './user_suspension.js';
