# 18: Executar gate de implantação e validação de produção

Status: ready-for-agent

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
