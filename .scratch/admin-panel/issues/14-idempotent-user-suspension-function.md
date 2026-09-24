# 14: Implementar Callable idempotente de Suspensão Administrativa

Status: ready-for-agent

Blocked by: 09 — Expor consultas administrativas mínimas de Conta de Usuário

Spec: §§ 17, 18, 19, 22 e Testing Decisions / Callable Functions.

**What to build:** `setUserSuspension` permite suspender ou reativar uma Conta de Usuário por ambiente confiável, com motivo obrigatório, proteção de administradores, registro imutável e reconciliação sob demanda de operações pendentes.

## Acceptance criteria

- [ ] Entrada aceita somente UID, `suspend`/`reactivate`, motivo normalizado de 10–500 caracteres e UUID v4 `operationId`.
- [ ] Function exige Auth, claim admin e App Check de produção, bloqueia autoação, alvo admin e conta inexistente.
- [ ] Suspender desabilita Auth e revoga refresh tokens; reativar habilita Auth sem prometer restaurar tokens antigos.
- [ ] Registro confiável contém Administrador, alvo, ação, motivo, timestamps, status e resultado/falha sanitizada; cliente não pode lê-lo ou escrevê-lo.
- [ ] Mesmo `operationId` com parâmetros diferentes é rejeitado; sucesso devolve resultado armazenado; falha devolve falha armazenada.
- [ ] Pending é reconciliado sob demanda; suspensão já desabilitada reaplica revogação idempotente antes de finalizar.
- [ ] Registros finalizados são imutáveis e não há scheduler, fila ou framework genérico.
- [ ] Testes cobrem todas as validações, estados Auth, interrupções entre serviços, idempotência e privacidade.

## Verification

- [ ] Executar typecheck/lint/testes de Functions e testes de Rules para negar acesso cliente aos registros.
