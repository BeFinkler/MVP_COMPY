# 11: Entregar Dashboard e descoberta administrativa de Locais Esportivos

Status: blocked

Blocked by: 03 — Introduzir contrato de Local Esportivo, Rules transitórias e migração; 10 — Proteger acesso e entregar shell do Painel Administrativo

Spec: §§ 6, 8, 20, 21 e Testing Decisions / Painel Flutter Web.

**What to build:** Um Administrador autenticado vê Dashboard operacional e catálogo de Locais Esportivos em tempo real, com contagens, atalhos, busca normalizada, filtros, paginação e estados de leitura claros. Não inclui ainda criação ou edição.

## Acceptance criteria

- [x] Dashboard mostra contagem de perfis Firestore, locais ativos e inativos com texto acessível sobre a semântica de “Usuários cadastrados”.
- [x] Atalhos levam a novo local, filtro de inativos e busca de Usuário sem carregar módulos fora do escopo.
- [x] Lista de locais usa snapshots, busca por prefixo, filtros combináveis de status/modalidade/cidade, ordem alfabética, cursores e páginas de 20.
- [x] Leitura cacheada exibe aviso claro de offline; loading inicial usa skeleton; paginação não bloqueia a tela inteira.
- [x] Estados vazio e erro são distintos, preservam filtros e oferecem retry.
- [x] Apenas Administrador consegue listar inativos; nenhum conteúdo é carregado antes do guard.
- [x] Testes cobrem agregações, consultas, cursores, filtros, atualizações em tempo real, cache, erro, vazio e acessibilidade.

## Verification

- [x] `flutter analyze --no-pub` — exit code 0 na execução concluída antes do ajuste de uma asserção de teste; a nova tentativa de confirmação nesta retomada não retornou e foi interrompida, sem alteração no código de produção.
- [x] `flutter test --no-pub` — 21 testes passaram, exit code 0.
- [x] `flutter build web --no-pub` — build concluído, exit code 0.
- [x] `node --check tools/firestore-rules-tests/places.test.js` — exit code 0.
- [x] `git diff --check` — exit code 0.
- [ ] Exercitar as consultas contra o Emulator; a execução nesta retomada não iniciou por `Unable to establish loopback connection` / `Invalid argument: connect`. A execução manual externa ainda é necessária.

### Bloqueio atual

A implementação e os testes locais do painel estão prontos, mas o ticket permanece `blocked` até que a suíte real de Firestore Rules execute no Emulator. O Emulator falhou ao abrir loopback no executor do Codex antes de iniciar os casos; isso não é evidência de falha nas Rules ou nos novos testes. Os oito cenários de consulta administrativa adicionados a `places.test.js` incluem as combinações de busca por prefixo e filtros; a configuração dos índices correspondentes foi conferida estaticamente. Não repetir a tentativa no Codex sem uma nova abordagem para o loopback.

Para validação externa, em PowerShell normal:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Bernardo Finkler\StudioProjects\MVP_COMPY\tools\scripts\run-firestore-rules-tests.ps1"
$rulesExitCode = $LASTEXITCODE
"Firestore Rules exit code: $rulesExitCode"
```

Marcar como `resolved` somente após a suíte completa passar com exit code 0.
