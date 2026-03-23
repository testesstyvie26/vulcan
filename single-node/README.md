# Deploy Vulcan Defense (Wazuh) in single node configuration

This deployment is defined in the `docker-compose.yml` file with one Wazuh manager, one Wazuh indexer, and one Wazuh dashboard container. It can be deployed by following these steps: 

## Pré-requisitos (Linux)

1) **vm.max_map_count** – **OBRIGATÓRIO** antes de subir os containers. Execute com root:
```bash
# Temporário (válido até reiniciar)
sudo sysctl -w vm.max_map_count=262144

# Permanente (recomendado)
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Verificar
cat /proc/sys/vm/max_map_count
# Deve retornar 262144 ou maior
```

2) Run the certificate creation script:
```
$ docker compose -f generate-indexer-certs.yml run --rm generator
```
3) Start the environment with docker compose:

- In the foregroud:
```
$ docker compose up
```
- In the background:
```
$ docker compose up -d
```

The environment takes about **1–2 minutes** to get up on first run while the Wazuh Indexer initializes and creates indexes.

## Vulcan Defense - Custom Branding

The dashboard is exposed on **port 443** via nginx (nginx.dashboard). Access at `https://<servidor>` (accept the self-signed certificate).

---

## Troubleshooting: "Vulcan dashboard server is not ready yet" em loop

Se o dashboard ficar preso nessa mensagem:

### 1. Verificar vm.max_map_count
```bash
cat /proc/sys/vm/max_map_count
```
Se retornar menos que 262144, configure e **reinicie os containers**:
```bash
sudo sysctl -w vm.max_map_count=262144
# Ou para OpenSearch mais recente:
sudo sysctl -w vm.max_map_count=1048576
```

### 2. Aguardar o Indexer
O indexer leva 1–2 minutos na primeira subida. Verifique os logs:
```bash
docker compose logs -f wazuh.indexer
```
Aguarde até ver mensagens indicando que o índice foi criado ou que o cluster está verde.

### 3. Verificar se o Indexer responde
```bash
curl -k -u admin:V3yulcan442 https://localhost:9200
```
(Use a senha definida no docker-compose; porta 9200 se estiver exposta.)

### 4. Reiniciar tudo na ordem correta
```bash
docker compose down
# Garantir vm.max_map_count
sudo sysctl -w vm.max_map_count=262144
docker compose up -d
# Aguardar 2–3 minutos antes de acessar
```

### 5. Ver logs do dashboard
```bash
docker compose logs -f wazuh.dashboard
```
Procure erros de conexão (ECONNREFUSED, 401, etc.).

### 6. Erro "Authentication finally failed" (admin / kibanaserver)

As senhas no `internal_users.yml` precisam corresponder ao `docker-compose` (admin: `V3yulcan442`, kibanaserver: `kibanaserver`). Execute o script de correção:

```bash
bash fix-internal-users.sh
```

Ou manualmente: gere os hashes com `hash.sh -p 'sua_senha'` no container, atualize `config/wazuh_indexer/internal_users.yml` e rode o `securityadmin` (porta **9200**).

### 7. "Vulcan Defense did not load properly"

Erro genérico que geralmente indica falha do plugin Wazuh ao conectar na API. Verifique:

**A) Wazuh API acessível:**
```bash
# Do host (porta 55000 do manager)
curl -k -u wazuh-wui:MyS3cr37P450r.*- https://localhost:55000/version

# Do container do dashboard
docker compose exec wazuh.dashboard curl -k -u wazuh-wui:MyS3cr37P450r.*- https://wazuh.manager:55000/version
```

**B) Logs do dashboard** (procure por erros de conexão com wazuh.manager):
```bash
docker compose logs wazuh.dashboard
```

**C) Se o manager estiver reiniciando** – o dashboard tenta carregar antes da API estar pronta. Aguarde 2–3 min e recarregue a página.

**D) Conferir wazuh.yml** – em `config/wazuh_dashboard/wazuh.yml` devem estar `url: "https://wazuh.manager"`, `port: 55000`, `username: wazuh-wui` e `password` iguais ao `API_PASSWORD` do docker-compose.

**E) Testar sem sub_filter** – comentar temporariamente as linhas `sub_filter` em `config/nginx/nginx.conf`, reiniciar nginx e testar:
```bash
docker compose restart nginx.dashboard
```

### 8. Erro "Not yet initialized (you may need to run securityadmin)"

Se os logs do indexer mostrarem esse erro, inicialize o plugin de segurança manualmente:

```bash
# 1. Obter o nome do container do indexer
docker compose ps

# 2. Executar o securityadmin dentro do container (substitua CONTAINER pelo nome real, ex: vulcan-wazuh-indexer-1)
docker compose exec wazuh.indexer bash -c '
  cd /usr/share/wazuh-indexer
  export JAVA_HOME=/usr/share/wazuh-indexer/jdk
  CACERT=/usr/share/wazuh-indexer/config/certs/root-ca.pem
  CERT=/usr/share/wazuh-indexer/config/certs/admin.pem
  KEY=/usr/share/wazuh-indexer/config/certs/admin-key.pem
  bash plugins/opensearch-security/tools/securityadmin.sh \
    -cd config/opensearch-security/ \
    -nhnv -cacert $CACERT -cert $CERT -key $KEY -p 9200 -icl
'

# 3. Reiniciar o dashboard para reconectar
docker compose restart wazuh.dashboard
```

**Nota:** Se `config/opensearch-security/` não tiver todos os arquivos (config.yml, roles.yml, etc.), use o diretório padrão do plugin:
```bash
docker compose exec wazuh.indexer bash -c '
  cd /usr/share/wazuh-indexer
  export JAVA_HOME=/usr/share/wazuh-indexer/jdk
  CACERT=/usr/share/wazuh-indexer/config/certs/root-ca.pem
  CERT=/usr/share/wazuh-indexer/config/certs/admin.pem
  KEY=/usr/share/wazuh-indexer/config/certs/admin-key.pem
  bash plugins/opensearch-security/tools/securityadmin.sh \
    -cd plugins/opensearch-security/securityconfig/ \
    -nhnv -cacert $CACERT -cert $CERT -key $KEY -p 9200 -icl
'
```
