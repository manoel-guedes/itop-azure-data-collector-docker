# iTop Azure Data Collector — Docker

Containeriza o [Combodo Azure Data Collector](https://github.com/Combodo/combodo-azure-data-collector) para sincronizar recursos do Azure (VMs, Discos, App Services, AKS, Resource Groups, Subscriptions) com o iTop via REST API.

---

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Variáveis de ambiente](#variáveis-de-ambiente)
- [Configuração](#configuração)
- [Execução local](#execução-local)
- [Deploy no Azure Container Instances](#deploy-no-azure-container-instances)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Troubleshooting](#troubleshooting)
- [Licença](#licença)

---

## Pré-requisitos

| Requisito | Versão mínima |
|---|---|
| Docker | 20+ |
| Azure CLI | 2.50+ |
| Conta Azure | Service Principal com Reader no(s) subscription(s) |
| iTop | 3.x com módulo `combodo-azure-data-collector` instalado |

---

## Variáveis de ambiente

Crie um arquivo `.env` na raiz do projeto (nunca comite este arquivo):

```env
ITOP_URL=https://seu-itop.exemplo.com/
ITOP_LOGIN=data_collector
ITOP_PASSWORD=senha_segura

MS_CLIENTID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
MS_CLIENTSECRET=seu_client_secret
MS_TENANTID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

SYNCHRO_USER=data_collector
CONTACT_TO_NOTIFY=admin@exemplo.com
```

> **Permissões Azure necessárias:** o Service Principal (`MS_CLIENTID`) precisa da role **Reader** nas subscriptions que serão coletadas.

---

## Configuração

O arquivo `params.local.xml` usa placeholders `${VAR}` que são substituídos pelas variáveis de ambiente na inicialização do container via `envsubst`. Não é necessário editar o XML diretamente — basta ajustar o `.env`.

Para customizações avançadas (org_id, status padrão dos objetos, etc.), edite `params.local.xml` antes de fazer o build.

---

## Execução local

### Build

```sh
docker build -t ci-itop-azure-sync:latest .
```

### Run

```sh
docker run --rm --env-file .env ci-itop-azure-sync:latest
```

O container executa o collector e termina (sem daemon). O PHP roda com `memory_limit=1G` para suportar ambientes Azure grandes.

---

## Deploy no Azure Container Instances

### Pré-requisitos

- Azure Container Registry (ACR) com a imagem publicada
- Resource Group destino criado

### Script automatizado (PowerShell)

O arquivo `deploy.ps1` (não versionado — ver `.gitignore`) contém o pipeline completo:

1. `docker build` — gera a imagem localmente  
2. `az acr login` + `docker push` — publica no ACR  
3. `az container create` — recria o ACI com a nova imagem

```powershell
.\deploy.ps1
```

### Comando manual

```powershell
az container create `
  --resource-group rg-itop `
  --name ci-itop-azure-sync `
  --image <acr>.azurecr.io/ci-itop-azure-sync:latest `
  --os-type Linux `
  --cpu 1 --memory 1.5 `
  --restart-policy Never `
  --registry-login-server <acr>.azurecr.io `
  --registry-username <acr> `
  --registry-password "<acr_password>" `
  --environment-variables `
      ITOP_URL=https://seu-itop.exemplo.com/ `
      ITOP_LOGIN=data_collector `
      MS_CLIENTID=<client_id> `
      MS_TENANTID=<tenant_id> `
      SYNCHRO_USER=data_collector `
  --secure-environment-variables `
      ITOP_PASSWORD="<senha>" `
      MS_CLIENTSECRET="<secret>"
```

> **`--restart-policy Never`** é obrigatório — o collector é uma tarefa pontual, não um serviço contínuo.

### Agendamento

Use uma **Azure Logic App** com trigger de recorrência apontando para a [API de start do ACI](https://learn.microsoft.com/azure/container-instances/container-instances-restart-policy) para executar a sincronização periodicamente.

---

## Estrutura do projeto

```
.
├── Dockerfile                   # Build da imagem PHP 8.1-cli + collector
├── params.local.xml             # Template de configuração com placeholders ${VAR}
├── combodo-azure-data-collector-2_0_1.zip  # Pacote do collector (não versionado no git)
├── .env                         # Credenciais locais (não versionado)
├── deploy.ps1                   # Script de build + push + deploy ACI (não versionado)
├── .gitignore
└── Readme.md
```

---

## Troubleshooting

### `${ITOP_URL}` aparece literal no XML

O container precisa receber as variáveis de ambiente. Certifique-se de usar `--env-file .env` no `docker run`.

### `php_network_getaddresses: getaddrinfo failed` (no collector)

O container não consegue resolver o hostname do iTop. Verifique conectividade de rede do ambiente onde o container está rodando.

### `rest.php replied: mysqli::real_connect() ... getaddrinfo failed`

Este erro é do **servidor iTop**, não do collector. O iTop está com problema na conexão com seu banco de dados MySQL. Verifique o serviço de banco no servidor iTop.

### `Allowed memory size exhausted`

O PHP padrão usa 128 MB. A imagem já configura `memory_limit=1G` no CMD. Se o problema persistir, aumente o valor no `Dockerfile`:

```dockerfile
CMD ["/bin/sh", "-c", "envsubst < conf/params.local.xml.template > conf/params.local.xml && php -d memory_limit=2G exec.php"]
```

### ACI — erros comuns no `az container create`

| Erro | Causa | Fix |
|---|---|---|
| `InvalidOsType` | `--os-type` ausente | Adicionar `--os-type Linux` |
| `ResourceRequestsNotSpecified` | CPU/memória ausentes | Adicionar `--cpu 1 --memory 1.5` |
| `InaccessibleImage` | Credenciais ACR ausentes | Adicionar `--registry-*` |

---

## Licença

GPL License — baseado no [combodo-azure-data-collector](https://github.com/Combodo/combodo-azure-data-collector).
