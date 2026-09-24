# 13: Entregar descoberta e detalhe administrativo de Usuário

Status: ready-for-agent

Blocked by: 08 — Normalizar Perfis de Usuário para pesquisa administrativa; 09 — Expor consultas administrativas mínimas de Conta de Usuário; 10 — Proteger acesso e entregar shell do Painel Administrativo

Spec: §§ 14, 15, 16, 21 e Testing Decisions / Painel Flutter Web.

**What to build:** O painel permite listar e pesquisar Perfis de Usuário por seletor explícito, consultar detalhes Auth mínimos e apresentar corretamente contas sem perfil, perfis sem conta e estado indisponível. Não inclui ainda mutação de conta.

## Acceptance criteria

- [ ] Seletor explícito oferece Nome, Handle, UID e E-mail sem inferência ou consultas paralelas ocultas.
- [ ] Nome e Handle usam prefixo paginado de 20 perfis; UID e E-mail usam consulta Auth exata.
- [ ] Lista exibe avatar, nome, handle, modalidades favoritas e estado obtido por uma chamada em lote por página.
- [ ] Detalhe exibe somente dados públicos aprovados e metadados Auth mínimos.
- [ ] Conta Auth sem perfil mostra `Perfil não encontrado`; perfil sem Auth mostra `Conta não encontrada` e não oferece ação futura.
- [ ] Falha do lote mostra `Estado indisponível`, sem supor estado ativo.
- [ ] Estados de loading, cache/offline, vazio, erro, paginação, retry, teclado e foco são tratados.
- [ ] Testes cobrem todos os tipos de busca, paginação, resultados ausentes, falha do lote e privacidade do payload.

## Verification

- [ ] Executar análise e testes do painel.
- [ ] Validar integração com emulador/fakes dos dois contratos Callable.
