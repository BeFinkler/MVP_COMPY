# 08: Normalizar Perfis de Usuário para pesquisa administrativa

Status: ready-for-agent

Blocked by: 02 — Preparar tooling confiável Firebase e fundação de Functions

Spec: §§ 14, 15, 24 e Testing Decisions / Firestore Rules, Mobile e Scripts.

**What to build:** Perfis de Usuário passam a manter `nameLower` e a proteger `handle` e `createdAt` após criação; um backfill idempotente prepara perfis existentes para busca administrativa sem alterar sua identidade ou expor dados privados.

## Acceptance criteria

- [ ] Fluxos confiáveis do mobile escrevem `nameLower` de acordo com o normalizador pt-BR ao criar/regravar perfil.
- [ ] Rules transitórias aceitam perfil legado enquanto impedem mutação de `handle` e `createdAt`; Rules finais exigem o campo novo conforme a sequência aprovada.
- [ ] Busca por prefixo de nome é possível sem carregar todos os perfis; busca por handle mantém o contrato atual.
- [ ] Script de backfill é idempotente, trata nomes acentuados, reporta documento sem nome válido e nunca inventa dados.
- [ ] Leitura de dados privados continua fora do perfil público e fora do acesso administrativo direto.
- [ ] Testes cobrem normalizador, escrita mobile, regras de imutabilidade, query de prefixo e script.

## Verification

- [ ] Executar testes Dart afetados, Rules no emulador e testes do script.
