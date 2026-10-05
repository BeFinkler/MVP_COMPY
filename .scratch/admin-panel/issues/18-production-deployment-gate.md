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

## Bloqueios externos identificados em 2026-10-03 (histórico)

- O Firebase CLI local v15.31.0 está autenticado e `projects:list` confirmou que `compy-tcc` é visível. Permissão de deploy não foi testada.
- A listagem remota somente leitura encontrou apenas o site padrão `compy-tcc.web.app`; não existe mapeamento `hosting.admin` em `.firebaserc` nem site dedicado associado ao target. Nenhum site/target foi criado.
- A listagem remota de índices retornou seis índices compostos; não expôs estado `READY`. Os sete índices de `places` presentes em `firestore.indexes.json` não apareceram na listagem remota, portanto ainda precisam ser publicados pela sequência aprovada e observados até `READY`.
- Plano Blaze, orçamento/alertas, registro App Check/reCAPTCHA v3, site key, token debug autorizado e domínios permitidos não foram confirmados no Console. Nenhum valor ou segredo foi inventado ou versionado.
- O responsável ainda precisa confirmar endereço e imagem reais de `parque_do_trabalhador` antes da migração de produção.
- Não foram executados deploy, migração/backfill, smoke tests hospedados ou período de observação; não há versões implantadas para registrar. Essas etapas requerem os pré-requisitos acima e confirmação antes de cada deploy remoto.

O ticket permanece `blocked`; os critérios operacionais e smoke tests reais não foram satisfeitos. Não criar PR, não fazer merge e não publicar no repositório original até a conclusão e aprovação do gate.

## Retomada e auditoria remota em 2026-10-05

- Estado inicial preservado: branch `feat/admin-panel`, working tree limpo, HEAD local e `origin/feat/admin-panel` em `0969dd4d955d42a8e3a3b3773f6c5ffa07767bd8`. O fork continua como `origin`, e o original como `upstream`.
- Blaze confirmado diretamente na Cloud Billing API: `billingEnabled: true` e conta de cobrança vinculada. Nenhuma associação de conta, cartão, plano ou billing foi alterada nesta execução.
- CLI Firebase autenticada com acesso ao projeto `compy-tcc` / número `260166625635`. A consulta IAM confirmou permissões de criação/atualização de Functions, criação/atualização de Hosting, atualização de releases de Rules, criação de índices e habilitação de APIs. Deploy ainda não foi executado.
- Firestore remoto: database `(default)`, `FIRESTORE_NATIVE`, região `southamerica-east1`. Os seis índices existentes de eventos/conversas estão `READY`; os sete índices locais de `places` ainda estão ausentes.
- Rules remotas ainda diferem de `firestore.rules` final. A evidência final de 132/132 testes, exit code 0, continua válida; nenhuma Rule foi modificada nesta retomada.
- Cloud Functions API ainda não estava habilitada na consulta inicial; portanto a listagem remota não confirma Functions publicadas. A publicação das três Callables continua pendente, com região `southamerica-east1`, gen2 e App Check obrigatório.
- Site dedicado `compy-tcc-admin` criado pelo Firebase CLI e associado ao Web App existente `1:260166625635:web:c6f717d9c7d38c4f79cb56` (`mvp_compy (web)`). Target local `hosting.admin` associado a esse site em `.firebaserc`. Domínios reservados: `compy-tcc-admin.web.app` e `compy-tcc-admin.firebaseapp.com`. Ainda não há release do painel nesse site.
- Authentication remoto permite e-mail/senha e autenticação anônima. Os dois domínios do novo site foram acrescentados a `authorizedDomains`, preservando `localhost` e os dois domínios do site padrão.
- App Check do Web App: `recaptchaV3Config.siteSecretSet == false`; nenhum token debug registrado. Falta registrar reCAPTCHA v3 para os domínios reais do painel e fornecer a site key pública ao build. A chave secreta deve ser inserida somente no Console. O enforcement global do Firestore permanece `UNENFORCED`.
- A Cloud Billing Budget API foi habilitada no projeto somente para permitir a consulta. Com o projeto de quota correto, a API retornou `403 PERMISSION_DENIED`: a conta atual não pode listar orçamentos da conta de cobrança. O responsável pela cobrança precisa confirmar/criar orçamento e alertas; nenhum valor financeiro foi escolhido e nenhum orçamento foi criado automaticamente.
- `places/parque_do_trabalhador` não existe no Firestore remoto. O endereço e as coordenadas fornecidos pelo responsável coincidem com o seed. A imagem do seed é uma URL Unsplash genérica; antes da migração, ainda é necessária uma imageUrl HTTPS real aprovada para o Parque. Não foi executada migração/backfill.
- Validações locais repetidas nesta retomada: Admin `flutter analyze --no-pub` sem issues, exit code 0; `flutter test --no-pub --reporter expanded` com 50 testes aprovados, exit code 0; `flutter build web --no-pub` exit code 0. O build é somente evidência de compilação: não possui a site key externa obrigatória, portanto não deve ser publicado. Functions: typecheck, lint e testes 19/19, todos com exit code 0.
- Os deploys permanecem pendentes até confirmação de orçamento/alertas e registro App Check. Publicar Rules finais também depende da sequência expand–contract e dos smoke tests reais definidos na spec; não é seguro substituir antecipadamente as Rules antigas somente porque os testes locais passaram.

O bloqueio de Spark foi superado. O ticket permanece `blocked` pelo gate de produção: orçamento/alertas não confirmados, reCAPTCHA/App Check sem registro, imagem real e conta administrativa ainda não confirmadas, deploys e smoke tests pendentes. As autorizações de deploy e finalização Git fornecidas pelo responsável serão usadas quando esses pré-requisitos estiverem satisfeitos; não é necessário solicitar novamente autorização genérica para essas operações.

## Registro App Check concluído em 2026-10-05

- O responsável criou a chave reCAPTCHA `COMPY Admin` no projeto `compy-tcc`: Web `SCORE`, restrita a `compy-tcc-admin.web.app` e `compy-tcc-admin.firebaseapp.com`, sem modo de teste e sem permitir todos os domínios.
- A interface Firebase apresentou o aviso de descontinuação do reCAPTCHA Classic e não permitiu ao responsável preencher o registro. A configuração foi concluída pelas APIs oficiais: recuperação da legacy secret key da chave existente e PATCH somente de `siteSecret` em `recaptchaV3Config` do Web App `1:260166625635:web:c6f717d9c7d38c4f79cb56`.
- GET de verificação confirmou `siteSecretSet: true`, `tokenTtl: 86400s` e `minValidScore: 0.5`. O provider do painel permanece reCAPTCHA v3, conforme a spec. A secret foi transferida somente em memória entre as APIs autenticadas; não foi exibida, gravada em arquivo ou versionada.
- Esse registro confirma a configuração do provider, não a emissão de token válido pelo painel hospedado. Smoke test de produção e observação das métricas continuam pendentes. O enforcement global do Firestore não foi alterado.
- Build Web de release gerado com a site key pública real fornecida por `--dart-define=COMPY_RECAPTCHA_V3_SITE_KEY`, sem token debug: `flutter build web --no-pub`, exit code 0. O artefato ignorado pelo Git fica em `admin/build/web`; ainda não foi publicado no Hosting.
- O próximo bloqueio operacional é confirmação de orçamento/alertas pelo responsável por billing. Imagem real do Parque, bootstrap administrativo, token debug local e demais critérios de implantação continuam pendentes. Ticket 18 permanece `blocked`.
