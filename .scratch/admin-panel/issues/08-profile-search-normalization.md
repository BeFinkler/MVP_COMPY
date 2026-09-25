# 08: Normalizar Perfis de Usuário para pesquisa administrativa

Status: blocked

Blocked by: 02 — Preparar tooling confiável Firebase e fundação de Functions

Spec: §§ 14, 15, 24 e Testing Decisions / Firestore Rules, Mobile e Scripts.

**What to build:** Perfis de Usuário passam a manter `nameLower` e a proteger `handle` e `createdAt` após criação; um backfill idempotente prepara perfis existentes para busca administrativa sem alterar sua identidade ou expor dados privados.

## Acceptance criteria

- [x] Fluxos confiáveis do mobile escrevem `nameLower` de acordo com o normalizador pt-BR ao criar/regravar perfil.
- [x] Rules transitórias aceitam perfil legado enquanto impedem mutação de `handle` e `createdAt`; Rules finais exigem o campo novo conforme a sequência aprovada.
- [x] Busca por prefixo de nome é possível sem carregar todos os perfis; busca por handle mantém o contrato atual.
- [x] Script de backfill é idempotente, trata nomes acentuados, reporta documento sem nome válido e nunca inventa dados.
- [x] Leitura de dados privados continua fora do perfil público e fora do acesso administrativo direto.
- [x] Testes cobrem normalizador, escrita mobile, regras de imutabilidade, query de prefixo e script.

## Verification

- [ ] Executar testes Dart afetados: bloqueado pelo hook de native assets de `objective_c` neste ambiente Windows com espaço no caminho do SDK; os testes não chegaram a iniciar.
- [ ] Executar Rules no Emulator: bloqueado pela falha conhecida de loopback Java do Firebase Emulator (ticket 03).
- [x] Executar testes do script: `npm test --prefix tools/firebase-admin` passou (34 testes).

Implementation complete; validation remains blocked exclusivamente pelos ambientes Flutter/Emulator acima. As Rules finais serão publicadas na fase expand--contract prevista na spec, não como alteração ad hoc deste ticket.
