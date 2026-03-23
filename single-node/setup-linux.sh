#!/bin/bash
# Vulcan Defense - Setup para Linux (pré-requisitos antes de docker compose up)
# Execute com: sudo ./setup-linux.sh

set -e

echo "=== Vulcan Defense - Setup Linux ==="

# 1. vm.max_map_count (OBRIGATÓRIO para Wazuh Indexer/OpenSearch)
CURRENT=$(cat /proc/sys/vm/max_map_count 2>/dev/null || echo "0")
REQUIRED=262144

if [ "$CURRENT" -lt "$REQUIRED" ]; then
  echo "Configurando vm.max_map_count=$REQUIRED (atual: $CURRENT)..."
  sysctl -w vm.max_map_count=$REQUIRED
  
  # Tornar permanente
  if ! grep -q "vm.max_map_count" /etc/sysctl.conf 2>/dev/null; then
    echo "vm.max_map_count=$REQUIRED" >> /etc/sysctl.conf
    echo "Persistido em /etc/sysctl.conf"
  fi
  echo "vm.max_map_count configurado com sucesso."
else
  echo "vm.max_map_count já OK ($CURRENT >= $REQUIRED)"
fi

# Verificação final
FINAL=$(cat /proc/sys/vm/max_map_count)
echo ""
echo "vm.max_map_count atual: $FINAL"
echo ""
echo "Próximos passos:"
echo "  1. docker compose -f generate-indexer-certs.yml run --rm generator  # se ainda não gerou certs"
echo "  2. docker compose up -d"
echo "  3. Aguardar 2-3 minutos antes de acessar https://localhost"
echo ""
