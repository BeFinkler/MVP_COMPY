# 12: Entregar ciclo seguro de criação, edição e status de Local Esportivo

Status: ready-for-agent

Blocked by: 03 — Introduzir contrato de Local Esportivo, Rules transitórias e migração; 11 — Entregar Dashboard e descoberta administrativa de Locais Esportivos

Spec: §§ 5, 6, 7, 21 e Testing Decisions / Painel Flutter Web.

**What to build:** O Administrador cria Local Esportivo inativo, edita conteúdo completo, visualiza mapa/imagem, ativa, desativa e reativa com confirmação e proteção contra conflito de `updatedAt`.

## Acceptance criteria

- [ ] Formulário valida todos os campos do schema, modalidades, endereço, CEP, UF, coordenadas e URL HTTPS antes de enviar.
- [ ] Mapa permite selecionar ponto e editar latitude/longitude; coordenada distante de Taquara produz aviso não bloqueante.
- [ ] Preview de imagem, validação inline, resumo de erros, preservação de valores e confirmação de saída funcionam.
- [ ] Criação gera somente local completo `inactive` e informa sucesso apenas após confirmação de servidor.
- [ ] Edição usa transação e versão `updatedAt`; conflito não sobrescreve nem apaga o formulário e oferece recarregar.
- [ ] Ativação/desativação/reativação são ações separadas; desativação explica impacto e pede confirmação.
- [ ] Escritas não são suportadas offline, não entram em estado otimista e não possuem fila própria.
- [ ] Nenhuma ação oferece exclusão física.
- [ ] Testes cobrem validações, transação, conflito, estado offline, confirmações, preview e acessibilidade.

## Verification

- [ ] Executar análise e testes do painel.
- [ ] Executar Rules no emulador para as mutações exercidas pela UI.
