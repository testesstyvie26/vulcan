#!/bin/bash
# Vulcan Defense - Corrige senhas do indexer (admin e kibanaserver)
# Executar no servidor Ubuntu: bash fix-internal-users.sh

set -e
cd "$(dirname "$0")"

ADMIN_PASS="${INDEXER_ADMIN_PASSWORD:-V3yulcan442}"
KIBANA_PASS="${DASHBOARD_PASSWORD:-kibanaserver}"
CONFIG_DIR="config/wazuh_indexer"
INTERNAL_USERS="$CONFIG_DIR/internal_users.yml"

echo "=== Gerando hashes bcrypt ==="

# Gerar hashes usando a imagem do indexer
hash_cmd() {
  docker run --rm wazuh/wazuh-indexer:4.14.3 \
    bash -c "/usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh -p '$1'" 2>/dev/null | tail -1
}

echo "Gerando hash para admin ($ADMIN_PASS)..."
ADMIN_HASH=$(hash_cmd "$ADMIN_PASS")
echo "Gerando hash para kibanaserver ($KIBANA_PASS)..."
KIBANA_HASH=$(hash_cmd "$KIBANA_PASS")

if [ -z "$ADMIN_HASH" ] || [ -z "$KIBANA_HASH" ]; then
  echo "ERRO: Falha ao gerar hashes. Certifique-se de que o Docker está rodando."
  exit 1
fi

echo "Hash admin ok, hash kibanaserver ok"

# Backup e atualização
cp "$INTERNAL_USERS" "${INTERNAL_USERS}.bak"

# Substituir hashes (admin e kibanaserver)
awk -v admin_hash="$ADMIN_HASH" -v kibana_hash="$KIBANA_HASH" '
/^admin:/ { in_admin=1; in_kibana=0 }
/^kibanaserver:/ { in_admin=0; in_kibana=1 }
/^[a-z]/ && !/^admin:/ && !/^kibanaserver:/ { in_admin=0; in_kibana=0 }
in_admin && /hash:/ { sub(/: ".*"/, ": \"" admin_hash "\""); in_admin=0 }
in_kibana && /hash:/ { sub(/: ".*"/, ": \"" kibana_hash "\""); in_kibana=0 }
{ print }
' "$INTERNAL_USERS" > "${INTERNAL_USERS}.tmp" && mv "${INTERNAL_USERS}.tmp" "$INTERNAL_USERS"

echo ""
echo "=== Reiniciando indexer para carregar config ==="
docker compose up -d wazuh.indexer
echo "Aguardando 60 segundos o indexer iniciar..."
sleep 60

echo ""
echo "=== Executando securityadmin ==="
docker compose exec -T wazuh.indexer bash -c '
  cd /usr/share/wazuh-indexer
  export JAVA_HOME=/usr/share/wazuh-indexer/jdk
  CACERT=/usr/share/wazuh-indexer/config/certs/root-ca.pem
  CERT=/usr/share/wazuh-indexer/config/certs/admin.pem
  KEY=/usr/share/wazuh-indexer/config/certs/admin-key.pem
  bash plugins/opensearch-security/tools/securityadmin.sh \
    -cd config/opensearch-security/ \
    -nhnv -cacert $CACERT -cert $CERT -key $KEY -p 9200 -icl
' || {
  echo "Falha com config/opensearch-security/. Tentando plugins/opensearch-security/securityconfig/..."
  docker compose exec -T wazuh.indexer bash -c '
    cp config/opensearch-security/internal_users.yml plugins/opensearch-security/securityconfig/ 2>/dev/null || true
    cd /usr/share/wazuh-indexer
    export JAVA_HOME=/usr/share/wazuh-indexer/jdk
    CACERT=/usr/share/wazuh-indexer/config/certs/root-ca.pem
    CERT=/usr/share/wazuh-indexer/config/certs/admin.pem
    KEY=/usr/share/wazuh-indexer/config/certs/admin-key.pem
    bash plugins/opensearch-security/tools/securityadmin.sh \
      -cd plugins/opensearch-security/securityconfig/ \
      -nhnv -cacert $CACERT -cert $CERT -key $KEY -p 9200 -icl
  '
}

echo ""
echo "=== Reiniciando dashboard ==="
docker compose restart wazuh.dashboard

echo ""
echo "Concluído! Aguarde ~30 segundos e acesse https://<servidor>"
echo "Credenciais: admin / $ADMIN_PASS  ou  kibanaserver / $KIBANA_PASS"
