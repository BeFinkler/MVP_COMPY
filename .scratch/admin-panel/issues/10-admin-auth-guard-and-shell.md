# 10: Proteger acesso e entregar shell do Painel Administrativo

Status: ready-for-agent

Blocked by: 01 — Criar a fundação Flutter Web do Painel Administrativo

Spec: §§ 3, 4, 21 e Testing Decisions / Painel Flutter Web.

**What to build:** O Painel Administrativo passa a oferecer login por e-mail e senha, sessão por navegador, guard de claim e shell responsivo. O resultado demonstrável é que somente Administradores qualificados chegam a rotas administrativas, inclusive por deep link.

## Acceptance criteria

- [ ] `/login` autentica somente com e-mail e senha e não oferece cadastro ou Google Sign-In.
- [ ] Inicialização permanece em loading integral até resolver Firebase Auth, atualização de token, provider password, e-mail verificado e claim `admin`.
- [ ] Ausência de requisito administrativo encerra a sessão, limpa estado e direciona para `/unauthorized` com retorno ao login.
- [ ] `/login` e `/unauthorized` são públicas; dashboard, locais e usuários exigem o mesmo guard inclusive em deep link.
- [ ] Persistência Auth é `SESSION`.
- [ ] Shell usa Material 3, sidebar desktop/recolhível, cabeçalho e logout acessível, sem bottom navigation.
- [ ] Guard, login, logout, unauthorized, loading, deep links, teclado e foco possuem cobertura de testes.

## Verification

- [ ] Executar análise e testes do painel.
- [ ] Validar visualmente larguras ampla e reduzida com navegação por teclado.
