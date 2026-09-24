# 16: Preparar App Check, Firebase Hosting e runbook de implantação

Status: ready-for-agent

Blocked by: 01 — Criar a fundação Flutter Web do Painel Administrativo; 09 — Expor consultas administrativas mínimas de Conta de Usuário; 10 — Proteger acesso e entregar shell do Painel Administrativo

Spec: §§ 22, 23, 24, 25 e Further Notes / Riscos e dependências externas.

**What to build:** Configuração versionada e documentação operacional para o painel usar App Check Web, Firebase Hosting em target dedicado e Functions gen2, sem executar configurações remotas que dependem do responsável pelo projeto.

## Acceptance criteria

- [ ] Painel ativa App Check Web com reCAPTCHA v3 por configuração pública de build, sem token de debug ou segredo no Git.
- [ ] Ambiente local prevê debug provider/token por variável externa e falha de forma clara quando ausente.
- [ ] Configuração Firebase prevê target Hosting `admin`, artefato Web, URL sem `#` e rewrite SPA para todas as rotas.
- [ ] Functions ficam preparadas para `enforceAppCheck: true` em produção após validação do domínio hospedado.
- [ ] Runbook descreve exatamente pré-requisitos Blaze, orçamento, alertas, CLI autenticada, criação/associação do site, domínio autorizado, reCAPTCHA e token debug.
- [ ] Runbook separa passos locais seguros de passos remotos manuais e inclui rollback de Hosting, Rules, Functions e contract.
- [ ] Não ativa enforcement global do Firestore nem replay protection beta.
- [ ] Testes/análise locais verificam configuração e build sem exigir Console ou deploy.

## Verification

- [ ] Executar análise/testes/build Web locais.
- [ ] Validar sintaxe de configuração Firebase e revisar que nenhum segredo está rastreado.
