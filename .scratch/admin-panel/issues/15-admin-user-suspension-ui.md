# 15: Entregar controles de Suspensão Administrativa no painel

Status: ready-for-agent

Blocked by: 13 — Entregar descoberta e detalhe administrativo de Usuário; 14 — Implementar Callable idempotente de Suspensão Administrativa

Spec: §§ 15, 19, 21 e Testing Decisions / Painel Flutter Web.

**What to build:** O detalhe de Usuário oferece suspensão e reativação como ações sensíveis isoladas, usando a Callable idempotente e comunicando corretamente os limites da revogação de token.

## Acceptance criteria

- [ ] Suspender e reativar ficam separados de dados de perfil e não aparecem para Perfil sem Conta de Usuário.
- [ ] Ações exigem motivo válido e confirmação final com UID, ação e aviso adequado.
- [ ] UI não apresenta a suspensão como bloqueio instantâneo de todo ID token já emitido.
- [ ] Cada envio gera UUID novo; repetição de uma solicitação interrompida reutiliza o mesmo ID até obter resultado terminal.
- [ ] Controles ficam desabilitados durante a operação e nunca mudam estado otimisticamente.
- [ ] Sucesso usa snackbar; falha aparece próxima da ação; dados e motivo permanecem recuperáveis após falha.
- [ ] Tentativas sobre Administrador, próprio usuário ou estado já desejado recebem mensagem segura.
- [ ] Testes cobrem confirmação, validação, loading, sucesso, erro, retry idempotente e acessibilidade.

## Verification

- [ ] Executar análise e testes do painel contra fake/emulador Callable.
