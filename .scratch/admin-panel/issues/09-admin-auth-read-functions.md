# 09: Expor consultas administrativas mínimas de Conta de Usuário

Status: ready-for-agent

Blocked by: 02 — Preparar tooling confiável Firebase e fundação de Functions

Spec: §§ 16, 17, 22 e Testing Decisions / Callable Functions.

**What to build:** As Callables `getAdminUserAuthDetails` e `getAdminUsersAuthStatus` fornecem somente metadados Auth aprovados para Administradores, sem abrir acesso direto a dados privados ou criar API administrativa genérica.

## Acceptance criteria

- [ ] Ambas as Callables são gen2, TypeScript, `southamerica-east1` e exigem Auth, claim `admin === true` e App Check quando enforcement de produção estiver ativo.
- [ ] Detalhe aceita exatamente UID ou e-mail, valida whitelist e retorna somente UID, e-mail, verificação, providers, criação, último login e `disabled`.
- [ ] Consulta em lote aceita 1–20 UIDs sem duplicatas e retorna somente UID/`disabled`, omitindo contas ausentes.
- [ ] Erros de autenticação, autorização, payload e conta inexistente usam códigos seguros e não vazam detalhes internos.
- [ ] Nenhuma Function lê ou retorna documento privado de perfil.
- [ ] Testes cobrem todos os papéis, entradas inválidas, conta sem e-mail, providers múltiplos, lote e minimização de dados.

## Verification

- [ ] Executar typecheck/lint/testes das Functions e integração com emuladores/fakes adequados.
