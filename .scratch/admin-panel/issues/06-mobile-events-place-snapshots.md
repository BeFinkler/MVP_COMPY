# 06: Criar Eventos Esportivos com snapshot imutável de Local Esportivo

Status: ready-for-agent

Blocked by: 03 — Introduzir contrato de Local Esportivo, Rules transitórias e migração; 04 — Fornecer repository Firestore de Local Esportivo ao mobile

Spec: §§ 11, 13, 21 e Testing Decisions / Firestore Rules e Mobile.

**What to build:** A criação mobile de Evento Esportivo usa Local Esportivo ativo atual em transação online, grava `placeId` e `placeSnapshot`, preserva `location`, coordenadas e geohash, e mantém leitura compatível com eventos legados.

## Acceptance criteria

- [ ] Novo Evento Esportivo grava `placeId`, snapshot estruturado de nome/endereço/coordenadas, `coordinates`, `geohash` e `location` formatado.
- [ ] Criação lê e valida local ativo e modalidade dentro de transação; sem conexão não enfileira a escrita e preserva formulário.
- [ ] Mudança/desativação do local entre seleção e commit causa erro de revisão sem perder os outros campos.
- [ ] Stream de seleção invalida somente o local quando ele se torna inativo.
- [ ] Rules transitórias aceitam escritor novo e legado, validam local/snapshot no commit e preservam joins atuais.
- [ ] `sport`, `placeId` e `placeSnapshot` ficam imutáveis em updates; eventos legados continuam legíveis e não recebem snapshot inventado.
- [ ] Testes cobrem novo contrato, leitura legada, local ausente/inativo, modalidade incompatível, snapshot divergente, conflito e offline.

## Verification

- [ ] Executar testes Dart afetados, `flutter analyze` e suíte de Rules no emulador.
