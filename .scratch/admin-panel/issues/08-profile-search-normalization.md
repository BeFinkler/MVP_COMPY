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

- [x] Executar testes Dart afetados: 173 testes passaram usando o alias curto 8.3 do SDK Flutter; o hook `objective_c` executou. `flutter analyze lib test` não teve erros, mas saiu com exit code 1 por 10 diagnósticos informativos preexistentes.
- [ ] Executar Rules no Emulator: bloqueado pela falha conhecida de loopback Java do Firebase Emulator (ticket 03).
- [x] Executar testes do script: `npm test --prefix tools/firebase-admin` passou (34 testes).

Implementation complete; validation remains blocked exclusivamente pela execução real das Firestore Rules no Emulator. As Rules finais serão publicadas na fase expand--contract prevista na spec, não como alteração ad hoc deste ticket.

Atualização de validação (2026-09-28): o checkout principal tem caminho com
espaços, então foi criada uma worktree detached do mesmo commit em
`C:\compy-test`. O hook nativo `objective_c` ainda falhou quando chamado pelo
caminho longo real do Dart SDK. O Windows fornece um alias 8.3 existente
(`C:\Users\BERNAR~1\develop\flutter`); usando esse caminho somente no processo
de validação, o hook executou e `flutter test` passou com 173 testes. A
tentativa também revelou uma expressão Dart inválida ao preservar `createdAt`
em `_writeUserProfile`; ela foi corrigida com ramificação explícita e os
testes passaram depois da correção.

`flutter analyze lib test` concluiu sem erros de código, mas saiu com code 1
por 10 diagnósticos informativos já existentes (recomendações de `const` e
deprecações). O `flutter analyze` sem escopo também percorre `admin/` como se
fosse parte do app raiz e reporta imports do package independente sem resolver;
`admin/` possui seu próprio `pubspec.yaml`.

O ticket continua `blocked` somente pela suíte real das Firestore Rules no
Emulator, que não pôde iniciar devido à falha Java documentada no ticket 03.
Comando de validação para o mobile em uma sessão PowerShell usando o alias
curto do SDK:

```powershell
$env:FLUTTER_ROOT = 'C:\Users\BERNAR~1\develop\flutter'
$env:Path = "$env:FLUTTER_ROOT\bin;$env:Path"
Set-Location 'C:\compy-test'
flutter analyze lib test
flutter test
```
