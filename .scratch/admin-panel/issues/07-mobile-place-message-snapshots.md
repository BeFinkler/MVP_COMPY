# 07: Compartilhar Mensagem de Local com snapshot e fallback histórico

Status: ready-for-agent

Blocked by: 03 — Introduzir contrato de Local Esportivo, Rules transitórias e migração; 04 — Fornecer repository Firestore de Local Esportivo ao mobile

Spec: §§ 12, 13, 21 e Testing Decisions / Firestore Rules e Mobile.

**What to build:** O chat passa a compartilhar somente Local Esportivo ativo atual, com snapshot mínimo de nome, imagem e modalidade principal; cards preferem dados atuais, preservam histórico e mantêm fallback para mensagens legadas.

## Acceptance criteria

- [ ] Nova Mensagem de Local contém `placeId` e snapshot mínimo completo; mensagens de texto comum mantêm o formato atual.
- [ ] Compartilhamento valida local ativo online antes de gravar; sem conexão não enfileira e preserva a intenção para retry.
- [ ] Rules transitórias validam associação à conversa, remetente, local ativo e snapshot no commit sem quebrar mensagens legadas.
- [ ] Card usa documento atual quando disponível, indica local inativo e impede novos usos nesse estado.
- [ ] Falha de resolução usa snapshot; mensagem legada somente com ID sem resolução usa fallback visual genérico.
- [ ] Mensagens existentes permanecem imutáveis.
- [ ] Testes cobrem novo mapper, legado, fallback, inativo, offline e Rules de mensagem.

## Verification

- [ ] Executar `flutter analyze`, testes do chat e suíte de Rules no emulador.
