# 04: Fornecer repository Firestore de Local Esportivo ao mobile

Status: ready-for-agent

Blocked by: 03 — Introduzir contrato de Local Esportivo, Rules transitórias e migração

Spec: §§ 5, 10, 21 e Testing Decisions / Mobile.

**What to build:** A camada mobile que entende o schema de Local Esportivo e oferece stream de locais ativos, filtro por modalidade, resolução histórica por ID e metadados de cache. Este ticket não migra ainda todas as telas para a nova fonte.

## Acceptance criteria

- [ ] Modelo mobile representa endereço estruturado, `sports`, `primarySport`, status, coordenadas e imagem, sem campos fictícios de avaliação.
- [ ] Normalização pt-BR e formatação de endereço têm comportamento testado e compatível com o contrato.
- [ ] Repository Firestore observa somente locais ativos, ordenados por `nameLower`, e filtra por modalidade quando solicitado.
- [ ] Repository resolve local ativo ou inativo por ID para referência histórica.
- [ ] Chamadores distinguem dados de cache, dados confirmados, vazio e erro; não há cache persistente paralelo.
- [ ] Mocks/fixtures continuam disponíveis apenas para testes ou modo explicitamente mockado.
- [ ] Testes cobrem parsing, invalidez tolerada, ordenação, filtros, resolução inativa e metadados offline.

## Verification

- [ ] Executar testes Dart afetados e `flutter analyze` no mobile.
- [ ] Exercitar repository contra Firestore emulator/fakes conforme a suite existente permitir.
