# Deploy do Painel Administrativo COMPY

Este runbook cobre a configuração local e os passos manuais para Firebase App
Check, Hosting e Cloud Functions. Os comandos de deploy abaixo são operações
remotas e não foram executados durante a implementação deste ticket.

## Estado e limites

- O projeto é `compy-tcc`; o Hosting usa um target dedicado `admin` e publica
  `admin/build/web`.
- O painel usa rotas por path, sem `#`, e o Hosting reescreve rotas para
  `index.html`.
- As três Callable Functions administrativas usam `enforceAppCheck: true`.
  App Check complementa Auth, custom claim e Firestore Rules.
- Não habilite enforcement global do Firestore nem replay protection beta como
  parte deste MVP.
- Service accounts, chave secreta reCAPTCHA, token App Check de debug e arquivos
  `.env` com segredos nunca entram no Git.

## Pré-requisitos manuais

1. No Firebase Console, confirme que `compy-tcc` está no plano Blaze. Cloud
   Functions gen2 exige Blaze.
2. No Google Cloud Console, crie um orçamento e alertas de custo antes dos
   deploys. Escolha valores compatíveis com o orçamento do projeto; este
   runbook não define valores financeiros.
3. Instale/atualize o Firebase CLI por fonte oficial e autentique a conta com
   acesso ao projeto:

   ```powershell
   firebase login
   firebase projects:list
   firebase use compy-tcc
   ```

4. Crie um site de Hosting com um ID disponível escolhido no Console/CLI. O ID
   precisa ser único no Firebase; não presuma que um nome está livre:

   ```powershell
   firebase hosting:sites:create <SITE_ID> --project compy-tcc
   firebase target:apply hosting admin <SITE_ID> --project compy-tcc
   ```

   O segundo comando grava o mapeamento real do target `admin` em
   `.firebaserc`. Revise e versione essa alteração após confirmar que o site
   pertence ao projeto `compy-tcc`.

5. No Firebase Console, em **App Check → Apps**, registre/configure o app Web
   COMPY Admin para reCAPTCHA v3. No Console do reCAPTCHA, permita o domínio
   real atribuído ao Hosting (por exemplo, `<SITE_ID>.web.app` e
   `<SITE_ID>.firebaseapp.com`, conforme os domínios efetivamente exibidos).
   Guarde a site key pública para a configuração de build; mantenha a secret
   key somente no Console. Nunca adicione `localhost` à lista de domínios
   reCAPTCHA de produção.

6. Depois de iniciar o painel local pela primeira vez, registre o token de
   debug em **App Check → Apps → COMPY Admin → Manage debug tokens**. O token
   autoriza chamadas de um dispositivo sem attestation e deve permanecer fora
   do Git e de builds de produção.

## Desenvolvimento local com App Check

O app ativa o mecanismo oficial de debug do Firebase Web somente em modo debug
e em `localhost`, `127.0.0.1` ou `::1`. O token e a site key são configurações
externas ao repositório. A ausência de qualquer uma ou uma origem não local
interrompe a inicialização com uma mensagem explícita.

Na primeira execução, solicite que o SDK gere um token. Abra o DevTools do
navegador, copie o token emitido no console e registre-o no Firebase Console:

```powershell
$env:COMPY_APPCHECK_DEBUG_TOKEN = 'generate'
$env:COMPY_RECAPTCHA_V3_SITE_KEY = Read-Host 'Site key pública reCAPTCHA v3'
.\admin\tool\run_local_web.ps1
```

Nas execuções seguintes, leia o token sem gravá-lo em comandos versionados e
execute o mesmo script:

```powershell
$env:COMPY_APPCHECK_DEBUG_TOKEN = Read-Host 'Token App Check de debug registrado'
$env:COMPY_RECAPTCHA_V3_SITE_KEY = Read-Host 'Site key pública reCAPTCHA v3'
.\admin\tool\run_local_web.ps1
Remove-Item Env:COMPY_APPCHECK_DEBUG_TOKEN
Remove-Item Env:COMPY_RECAPTCHA_V3_SITE_KEY
```

Nunca use o script de debug para gerar artefato de produção ou fazer deploy.

## Build e deploy manual

Antes do build de release, carregue a site key pública no ambiente e garanta
que `COMPY_APPCHECK_DEBUG_TOKEN` não esteja definido:

```powershell
$env:COMPY_RECAPTCHA_V3_SITE_KEY = Read-Host 'Site key pública reCAPTCHA v3'
.\admin\tool\build_web.ps1
Remove-Item Env:COMPY_RECAPTCHA_V3_SITE_KEY
```

O script falha se a site key estiver ausente ou se houver token de debug no
ambiente. O build fica em `admin/build/web`. Antes de publicar, confirme que o
site ID de Hosting associado ao target `admin` e o domínio autorizado no App
Check são os valores reais do projeto.

Deploy seletivo, manual e com a conta Firebase autenticada:

```powershell
firebase deploy --only hosting:admin --project compy-tcc
firebase deploy --only functions:administrative --project compy-tcc
```

As Functions devem ser publicadas somente depois que o painel hospedado obtiver
tokens App Check válidos. Acompanhe as métricas de App Check antes de exigir
proteção em qualquer serviço. Não publique Rules finais enquanto clientes
legados ainda precisarem gravar o contrato anterior; siga a sequência
expand–contract da spec.

## Rollback

- **Hosting:** use a ação de rollback da release anterior na página Hosting do
  Firebase Console. Valide login, autorização e chamadas antes de manter o
  rollback.
- **Functions:** publique novamente a versão conhecida como válida da codebase
  `administrative`; mantenha registros `pending`, `succeeded` e `failed`.
- **Rules e contrato:** antes de retornar a um writer mobile antigo, publique
  primeiro as Rules transitórias compatíveis. Nunca reverta o cliente antes
  das Rules que ele precisa.
- **App Check:** se houver falha operacional, ajuste temporariamente o
  enforcement da Callable afetada no Console e registre a decisão. Não remova
  Firebase Auth, custom claims ou validações das Rules como contingência.
- Não apague `places/parque_do_trabalhador`, operações administrativas ou
  índices durante rollback.
