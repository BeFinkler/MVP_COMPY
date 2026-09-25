# 14: Implementar Callable idempotente de Suspensão Administrativa

Status: blocked

Blocked by: 09 — Expor consultas administrativas mínimas de Conta de Usuário

Spec: §§ 17, 18, 19, 22 e Testing Decisions / Callable Functions.

**What to build:** `setUserSuspension` permite suspender ou reativar uma Conta de Usuário por ambiente confiável, com motivo obrigatório, proteção de administradores, registro imutável e reconciliação sob demanda de operações pendentes.

## Acceptance criteria

- [x] Entrada aceita somente UID, `suspend`/`reactivate`, motivo normalizado de 10–500 caracteres e UUID v4 `operationId`.
- [x] Function exige Auth, claim admin e App Check de produção, bloqueia autoação, alvo admin e conta inexistente.
- [x] Suspender desabilita Auth e revoga refresh tokens; reativar habilita Auth sem prometer restaurar tokens antigos.
- [x] Registro confiável contém Administrador, alvo, ação, motivo, timestamps, status e resultado/falha sanitizada; cliente não pode lê-lo ou escrevê-lo.
- [x] Mesmo `operationId` com parâmetros diferentes é rejeitado; sucesso devolve resultado armazenado; falha devolve falha armazenada.
- [x] Pending é reconciliado sob demanda; suspensão já desabilitada reaplica revogação idempotente antes de finalizar.
- [x] Registros finalizados são imutáveis e não há scheduler, fila ou framework genérico.
- [x] Testes cobrem todas as validações, estados Auth, interrupções entre serviços, idempotência e privacidade.

## Verification

- [x] Executar typecheck/lint/testes de Functions: `npm run typecheck`, `npm run lint` e `npm test` em `functions/` passaram (19 testes).
- [ ] Executar testes de Rules para negar acesso cliente aos registros: bloqueado pela falha conhecida de loopback Java do Firebase Emulator (ticket 03). O caso de negação foi adicionado à suíte para execução quando o Emulator estiver disponível.

Implementation complete; o status permanece bloqueado exclusivamente pela validação real das Firestore Rules no Emulator.
