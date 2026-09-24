# 11: Entregar Dashboard e descoberta administrativa de Locais Esportivos

Status: ready-for-agent

Blocked by: 03 — Introduzir contrato de Local Esportivo, Rules transitórias e migração; 10 — Proteger acesso e entregar shell do Painel Administrativo

Spec: §§ 6, 8, 20, 21 e Testing Decisions / Painel Flutter Web.

**What to build:** Um Administrador autenticado vê Dashboard operacional e catálogo de Locais Esportivos em tempo real, com contagens, atalhos, busca normalizada, filtros, paginação e estados de leitura claros. Não inclui ainda criação ou edição.

## Acceptance criteria

- [ ] Dashboard mostra contagem de perfis Firestore, locais ativos e inativos com texto acessível sobre a semântica de “Usuários cadastrados”.
- [ ] Atalhos levam a novo local, filtro de inativos e busca de Usuário sem carregar módulos fora do escopo.
- [ ] Lista de locais usa snapshots, busca por prefixo, filtros combináveis de status/modalidade/cidade, ordem alfabética, cursores e páginas de 20.
- [ ] Leitura cacheada exibe aviso claro de offline; loading inicial usa skeleton; paginação não bloqueia a tela inteira.
- [ ] Estados vazio e erro são distintos, preservam filtros e oferecem retry.
- [ ] Apenas Administrador consegue listar inativos; nenhum conteúdo é carregado antes do guard.
- [ ] Testes cobrem agregações, consultas, cursores, filtros, atualizações em tempo real, cache, erro, vazio e acessibilidade.

## Verification

- [ ] Executar análise e testes do painel.
- [ ] Exercitar consultas contra emulador e verificar que os índices aprovados cobrem todas as combinações.
