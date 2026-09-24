# 17: Endurecer contract final e remover fonte estática de produção

Status: ready-for-agent

Blocked by: 05 — Migrar mapa mobile para Locais Esportivos em tempo real; 06 — Criar Eventos Esportivos com snapshot imutável de Local Esportivo; 07 — Compartilhar Mensagem de Local com snapshot e fallback histórico; 12 — Entregar ciclo seguro de criação, edição e status de Local Esportivo

Spec: §§ 10, 11, 12, 13, 24, 25 e Critérios de aceite 44–45.

**What to build:** Depois da validação do escritor novo, as Rules finais deixam de aceitar novas escritas legadas de evento/mensagem e o mobile deixa de usar definitivamente o catálogo estático de Local Esportivo em produção, preservando fixtures e leitura de histórico.

## Acceptance criteria

- [ ] Critérios de validação real do escritor novo estão documentados e concluídos antes da mudança final de Rules.
- [ ] Rules finais exigem `placeId` e snapshot novo para toda nova criação de Evento Esportivo e Mensagem de Local, mantendo leitura legada.
- [ ] Atualizações de evento mantêm contexto histórico imutável e joins atuais continuam autorizados.
- [ ] Nenhum caminho de produção usa `SportPlace.all` ou `SportPlace.byId`; fixtures permanecem isoladas em testes/modo mockado explícito.
- [ ] Campos e UI de avaliações fictícias de local são removidos da produção; `ratings` não aceita alvo `place`.
- [ ] Testes de Rules, mobile e regressão passam com dados novos e legados.
- [ ] Rollback exige explicitamente Rules de transição antes de qualquer volta a build escritor antigo.

## Verification

- [ ] Executar `flutter analyze`, toda a suíte mobile e Rules no emulador.
- [ ] Revisar busca estática para confirmar ausência de fonte de produção legada.
