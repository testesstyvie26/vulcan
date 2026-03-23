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
