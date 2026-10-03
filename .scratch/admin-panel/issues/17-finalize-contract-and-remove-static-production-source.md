# 17: Endurecer contract final e remover fonte estática de produção

Status: blocked

Blocked by: 05 — Migrar mapa mobile para Locais Esportivos em tempo real; 06 — Criar Eventos Esportivos com snapshot imutável de Local Esportivo; 07 — Compartilhar Mensagem de Local com snapshot e fallback histórico; 12 — Entregar ciclo seguro de criação, edição e status de Local Esportivo

Spec: §§ 10, 11, 12, 13, 24, 25 e Critérios de aceite 44–45.

**What to build:** Depois da validação do escritor novo, as Rules finais deixam de aceitar novas escritas legadas de evento/mensagem e o mobile deixa de usar definitivamente o catálogo estático de Local Esportivo em produção, preservando fixtures e leitura de histórico.

## Acceptance criteria

- [x] Validação dos escritores novos documentada antes da contract final: Rules Emulator externo ticket 06 (116/116) e ticket 07 (123/123); os cenários usaram SDK cliente, escritores transacionais, snapshots e fixtures históricas. Isso é evidência do estágio expand, não substitui a suíte abaixo contra Rules finais.
- [x] Rules finais exigem `placeId` e snapshot novo para toda criação de Evento Esportivo e Mensagem de Local, mantendo leituras e updates históricos permitidos.
- [x] Atualizações de evento mantêm contexto histórico imutável e o caminho de join permanece restrito aos campos atuais.
- [x] Nenhum caminho de produção usa `SportPlace.all` ou `SportPlace.byId`; as declarações estáticas foram removidas e os dados de teste são fixtures locais.
- [x] A produção não contém campos/UI de avaliações fictícias de Local Esportivo; Rules limitam ratings a `user`/`event`.
- [ ] Suíte final de Rules passou com dados novos e legados — pendente: o Emulator saiu com code 1 antes de executar os testes neste executor; nenhum resultado/assertion do estado final foi produzido.
- [x] O rollback documentado exige restaurar Rules transitórias antes de voltar a um build escritor antigo (`docs/admin/firebase-deployment.md`).

## Verification

- [x] Suíte mobile completa — 200 testes aprovados, exit code 0.
- [x] Análise focada nos arquivos mobile alterados — sem issues, exit code 0. A análise de todo `lib test` retorna exit code 1 apenas por 10 lints informativos preexistentes em arquivos não alterados; sem erros/avisos nos arquivos do ticket.
- [x] Admin `flutter analyze` — sem issues, exit code 0; `flutter test` — 51 aprovados, exit code 0; `flutter build web --no-pub` — exit code 0.
- [x] Functions `typecheck`, `lint` e testes — exit code 0; 19 testes aprovados.
- [x] `node --check` para `events.test.js` e `conversations.test.js`; exit code 0.
- [x] Revisão estática de Rules e `git diff --check`.
- [x] Busca global no código executável confirma ausência de `SportPlace.all`/`SportPlace.byId`.
- [ ] Repetir a suíte real das Rules finais fora do executor do Codex e obter exit code 0.

## Implementação e bloqueio restante

- `firestore.rules` agora rejeita novas criações de eventos sem `placeId`/snapshot atual e novas mensagens placeId-only. Mensagens de texto continuam válidas. Leitura de documentos legados e updates de eventos legados permitidos são mantidos.
- Os testes agora negam writers legados de novas criações, confirmam leitura de mensagem placeId-only histórica, e mantêm os testes existentes de joins/imutabilidade.
- Removidas `SportPlace.parqueDoTrabalhador`, `SportPlace.all` e `SportPlace.byId` do modelo de produção; teste antigo de catálogo foi substituído por fixture criada dentro do teste. Nenhuma regra/índice de ratings precisou de alteração porque as Rules já recusavam `targetType: place` e não havia ratings de Local no UI/modelo de produção.
- Os índices não mudaram.
- Uma execução do runner selecionou corretamente Temurin Java 21 (`C:\Java\temurin-21\jdk-21.0.12.1+1`), mas o processo do Firestore Emulator encerrou com code 1 antes de iniciar a suíte. Os testes finais das Rules não rodaram; não se afirma aprovação. A validação precisa ser repetida manualmente no PowerShell normal.
- Deploy das Rules finais não foi feito. Mesmo após a suíte passar, a publicação deve seguir a sequência da spec: build mobile novo publicado/validado no ambiente real durante a janela curta, e só então deploy das Rules finais. Deploy remoto requer confirmação manual no ticket 18.
