# 03: Introduzir contrato de Local Esportivo, Rules transitórias e migração

Status: blocked

Blocked by: 02 — Preparar tooling confiável Firebase e fundação de Functions

Spec: §§ 5, 7, 8, 9, 13, 24 e Testing Decisions / Firestore Rules e Scripts.

**What to build:** O contrato Firestore completo de Local Esportivo, os sete índices necessários, Rules transitórias e um script idempotente para preparar `parque_do_trabalhador`. O resultado é verificável no emulador e não muda ainda o escritor mobile de produção.

## Acceptance criteria

- [x] `places` possui schema com whitelist, endereço estruturado, normalizações, modalidades permitidas, coordenadas, imagem HTTPS, status e timestamps de servidor.
- [x] Create administrativo aceita somente documento completo com status inicial `inactive`; update preserva `createdAt`, atualiza `updatedAt` e delete é negado.
- [x] Usuário autenticado lista apenas ativos e pode resolver por ID o contexto histórico; Administrador lista ativos e inativos e é o único escritor direto.
- [x] O arquivo de índices preserva os seis existentes e enumera os sete índices de `places` aprovados.
- [x] As Rules são expand–contract: não quebram leitores/escritores legados de eventos e mensagens nesta etapa.
- [x] Script de migração possui dry-run, cria `parque_do_trabalhador` somente se ausente, é no-op se equivalente e aborta em divergência.
- [x] O script usa valores aprovados, timestamps de servidor e credencial externa; não faz deploy nem cria segredo.
- [ ] Testes do emulador cobrem papéis, queries, schema inválido, timestamps, status, acesso histórico e negações.

## Verification

- [ ] Executar suíte de Rules no emulador com os novos casos (bloqueado por JDK 21 LTS).
- [x] Executar testes do script, incluindo create/no-op/divergência/dry-run.
- [x] Validar sintaxe do arquivo de índices; a sintaxe das Rules aguarda a compilação do emulador.

## Answer

Implementados o contrato de `places`, Rules transitórias, sete índices, seed
aprovado, migração idempotente e testes unitários. Eventos e mensagens não
foram alterados, preservando o escritor legado durante o expand–contract.

O tooling passou typecheck, lint e 30 testes, incluindo dry-run, criação,
no-op equivalente e abortamento por divergência. Os índices foram validados
como JSON com 13 entradas no total, sendo sete para `places`.

Bloqueio externo de ambiente: o Firebase CLI atual exige JDK 21+. O Temurin
21.0.12.1 LTS foi instalado localmente e confirmado como o `java.exe` usado
pelo processo do emulador, mas o Windows recusou o socket de loopback interno
do Java (`Unable to establish loopback connection`, `Invalid argument:
connect`) antes de a suíte carregar as Rules. A tentativa com o provider de
selector alternativo teve o mesmo resultado. É necessário executar a suíte em
um terminal Windows com loopback Java permitido antes de marcar o ticket como
resolvido. Nenhum deploy, credencial ou operação remota foi feita.
