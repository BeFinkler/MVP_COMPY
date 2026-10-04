# 18: Executar gate de implantação e validação de produção

Status: blocked

Blocked by: 08 — Normalizar Perfis de Usuário para pesquisa administrativa; 12 — Entregar ciclo seguro de criação, edição e status de Local Esportivo; 14 — Implementar Callable idempotente de Suspensão Administrativa; 15 — Entregar controles de Suspensão Administrativa no painel; 16 — Preparar App Check, Firebase Hosting e runbook de implantação; 17 — Endurecer contract final e remover fonte estática de produção

Spec: §§ 9, 13, 22–25, Testing Decisions / Scripts e implantação, e Further Notes / Riscos e dependências externas.

**What to build:** A execução controlada da sequência remota de implantação, smoke tests e observação inicial. Este ticket só começa quando o responsável tiver concluído os pré-requisitos manuais de Firebase e confirmado os dados reais da migração.

## Acceptance criteria

- [ ] Plano Blaze, orçamento e alertas estão confirmados pelo responsável.
- [ ] Site/target Hosting, domínio padrão, domínio autorizado do App Check, chave reCAPTCHA e token debug de desenvolvimento foram configurados externamente sem serem versionados.
- [ ] CLI autenticada e permissões de deploy foram confirmadas pelo responsável.
- [ ] Endereço e imagem de `parque_do_trabalhador` foram confirmados antes da execução do script remoto.
- [ ] Índices estão `READY` antes de publicar escritores dependentes.
- [ ] A sequência de deploy segue Rules transitórias, migração/backfill, mobile novo, validação, Hosting/Functions com App Check e Rules finais.
- [ ] Smoke tests reais cobrem login administrativo, deep link, Dashboard, locais, busca, conta sem perfil, perfil sem conta, suspensão, reativação e comportamento de token já emitido.
- [ ] Erros, custos, App Check e Functions são observados no período inicial; enforcement global do Firestore não é ativado neste ticket.
- [ ] Resultado da implantação, versões e decisão de rollback permanecem documentados sem segredos.

## Verification

- [ ] Executar somente após intervenção manual explícita do responsável e com confirmação antes de cada deploy remoto.
- [ ] Anexar evidências não sensíveis dos smoke tests e das versões implantadas.

## Gate local em 2026-10-03

- Mobile: `flutter test --no-pub` — 200 aprovados, exit code 0. Análise focada nos três arquivos mobile alterados no ticket 17 — sem issues, exit code 0. A análise de `lib test` termina com exit code 1 por 10 infos preexistentes (`prefer_const_*`/`withOpacity`), sem erros; a análise ampla também varre templates Dart de `firebase-tools` dentro de `node_modules` e relata imports ausentes nesses exemplos vendorizados.
- Admin: `flutter analyze --no-pub` sem issues, exit code 0; `flutter test --no-pub` — 51 aprovados, exit code 0; `flutter build web --no-pub` — exit code 0. Esse build comprova compilação, mas não é artefato de produção: a site key reCAPTCHA externa não foi fornecida e o build de release documentado exige essa configuração.
- Functions: typecheck e lint, exit code 0; testes — 19/19, exit code 0.
- Tooling Admin SDK: typecheck e lint, exit code 0; testes — 34/34, exit code 0.
- Firestore Rules finais: evidência manual externa fornecida pelo responsável e registrada no ticket 17 — 132/132, 17 suítes, exit code 0. A suíte não foi repetida neste gate.
- Configuração: `firebase.json` e `firestore.indexes.json` são JSON válidos; o projeto local é `compy-tcc`, a codebase Functions é `administrative`/Node 20, a região é `southamerica-east1`, Hosting declara `admin` → `admin/build/web` com rewrite SPA, e há 13 índices compostos locais (7 para `places`).
- Higiene: `git diff --check` passou; busca nos arquivos versionados não encontrou service account, chave privada, `.env` nem artefatos `node_modules`, builds ou logs.

## Bloqueios externos

- O Firebase CLI local v15.31.0 está autenticado e `projects:list` confirmou que `compy-tcc` é visível. Permissão de deploy não foi testada.
- A listagem remota somente leitura encontrou apenas o site padrão `compy-tcc.web.app`; não existe mapeamento `hosting.admin` em `.firebaserc` nem site dedicado associado ao target. Nenhum site/target foi criado.
- A listagem remota de índices retornou seis índices compostos; não expôs estado `READY`. Os sete índices de `places` presentes em `firestore.indexes.json` não apareceram na listagem remota, portanto ainda precisam ser publicados pela sequência aprovada e observados até `READY`.
- Plano Blaze, orçamento/alertas, registro App Check/reCAPTCHA v3, site key, token debug autorizado e domínios permitidos não foram confirmados no Console. Nenhum valor ou segredo foi inventado ou versionado.
- O responsável ainda precisa confirmar endereço e imagem reais de `parque_do_trabalhador` antes da migração de produção.
- Não foram executados deploy, migração/backfill, smoke tests hospedados ou período de observação; não há versões implantadas para registrar. Essas etapas requerem os pré-requisitos acima e confirmação antes de cada deploy remoto.

O ticket permanece `blocked`; os critérios operacionais e smoke tests reais não foram satisfeitos. Não criar PR, não fazer merge e não publicar no repositório original até a conclusão e aprovação do gate.
