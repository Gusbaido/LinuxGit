#!/usr/bin/env bash
# Deploy da aplicação do repositório do Denilson para o Apache (Ubuntu/WSL)
# Baixa em /tmp e publica em /var/www/html

set -euo pipefail

REPO_URL="https://github.com/denilsonbonatti/linux-site-dio.git"
WORKDIR="/tmp/linux-site-dio"
DOCROOT="/var/www/html"

# Precisa ser root/sudo
if [[ $EUID -ne 0 ]]; then
  echo "[ERRO] Rode com sudo."
  exit 1
fi

echo "[1/6] Atualizando pacotes e instalando dependências..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y git apache2 unzip curl

echo "[2/6] Habilitando/ligando o Apache..."
systemctl enable --now apache2 2>/dev/null || {
  service apache2 start || true
  update-rc.d apache2 defaults || true
}

echo "[3/6] Baixando aplicação em ${WORKDIR}..."
rm -rf "$WORKDIR"
git clone "$REPO_URL" "$WORKDIR"

echo "[4/6] Fazendo backup do conteúdo atual de ${DOCROOT} (se existir)..."
mkdir -p "${DOCROOT}_backup"
cp -a "$DOCROOT/." "${DOCROOT}_backup/" 2>/dev/null || true

echo "[5/6] Publicando aplicação no ${DOCROOT}..."
rm -rf "${DOCROOT:?}/"*
cp -a "$WORKDIR"/* "$DOCROOT"/

echo "[6/6] Ajustando permissões e reiniciando serviço..."
chown -R www-data:www-data "$DOCROOT"
find "$DOCROOT" -type d -exec chmod 755 {} \;
find "$DOCROOT" -type f -exec chmod 644 {} \;
systemctl restart apache2 2>/dev/null || service apache2 restart

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1/)
echo "[OK] Deploy concluído. HTTP local: ${HTTP_CODE}. Acesse: http://localhost"
