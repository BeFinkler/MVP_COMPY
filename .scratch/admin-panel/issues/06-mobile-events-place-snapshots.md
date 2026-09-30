# 06: Criar Eventos Esportivos com snapshot imutável de Local Esportivo

Status: blocked

Blocked by: None (03 e 04 resolvidos); validação real das Firestore Rules no Emulator ainda pendente por bloqueio de loopback no executor do Codex.

Spec: §§ 11, 13, 21 e Testing Decisions / Firestore Rules e Mobile.

**What to build:** A criação mobile de Evento Esportivo usa Local Esportivo ativo atual em transação online, grava `placeId` e `placeSnapshot`, preserva `location`, coordenadas e geohash, e mantém leitura compatível com eventos legados.

## Acceptance criteria

- [x] Novo Evento Esportivo grava `placeId`, snapshot estruturado de nome/endereço/coordenadas, `coordinates`, `geohash` e `location` formatado.
- [x] Criação lê e valida local ativo e modalidade dentro de transação; sem conexão não enfileira a escrita e preserva formulário.
- [x] Mudança/desativação do local entre seleção e commit causa erro de revisão sem perder os outros campos.
- [x] Stream de seleção invalida somente o local quando ele se torna inativo.
- [x] Rules transitórias aceitam escritor novo e legado, validam local/snapshot no commit e preservam joins atuais — implementação e casos de Rules adicionados; execução real permanece pendente.
- [x] `sport`, `placeId` e `placeSnapshot` ficam imutáveis em updates; eventos legados continuam legíveis e não recebem snapshot inventado — implementação e casos de Rules adicionados; execução real permanece pendente.
- [x] Testes cobrem novo contrato, leitura legada, local ausente/inativo, modalidade incompatível, snapshot divergente, conflito e offline — cobertura de Rules e testes mobile de snapshot, fluxo offline e invalidação por stream adicionados.

## Verification

- [x] Executar testes Dart afetados e `flutter analyze`.
- [ ] Executar a suíte real de Rules no Emulator.

Validação mobile desta implementação: `flutter analyze lib/features/events` sem issues (exit code 0); suíte focada de Eventos/snapshots com 28 testes aprovados (exit code 0); suíte mobile completa com 196 testes aprovados (exit code 0). `node --check tools/firestore-rules-tests/events.test.js` passou (exit code 0); `git diff --check` passou (exit code 0).

Bloqueio de validação: a tentativa real no executor do Codex falhou antes de iniciar os testes. `tools/firestore-rules-tests/firestore-debug.log` registra `Unable to establish loopback connection` / `Invalid argument: connect` ao abrir o selector Java Netty. Nenhuma assertion das Rules foi executada nesta execução. Rode `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Bernardo Finkler\StudioProjects\MVP_COMPY\tools\scripts\run-firestore-rules-tests.ps1"` em um PowerShell Windows normal e confirme exit code 0 antes de resolver este ticket.
