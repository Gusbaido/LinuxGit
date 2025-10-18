#!/usr/bin/env bash
# Infraestrutura como Código —  (WSL-friendly)
# Grupos: ti, vendas, rh | Diretórios base: /departamentos/{ti,vendas,rh}
# Usuários: ti01/ti02, vendas01/vendas02, rh01/rh02
# Admin opcional: mariana (add em sudo e adm)
# Uso: sudo ./infra_users_dirs.sh

set -euo pipefail

# --- 0) Pré‑requisitos -------
if [[ "${EUID}" -ne 0 ]]; then
  echo "[ERRO] Rode como root (use sudo)." >&2
  exit 1
fi

# --- 1) Definições -----
BASE_DIR="/departamentos"
GROUPS=(ti vendas rh)          # sem vírgulas

# Mapeamento grupo -> subdiretório (array associativo)
declare -A DIRS=(
  [ti]="$BASE_DIR/ti"
  [vendas]="$BASE_DIR/vendas"
  [rh]="$BASE_DIR/rh"
)

PUBLIC_DIR="$BASE_DIR/compartilhado"

# Usuários por grupo (login:comentário)
TI_USERS=(
  "ti01:Usuário TI 1"
  "ti02:Usuário TI 2"
)
VENDAS_USERS=(
  "vendas01:Usuário Vendas 1"
  "vendas02:Usuário Vendas 2"
)
RH_USERS=(
  "rh01:Usuário RH 1"
  "rh02:Usuário RH 2"
)

# Admin opcional (preencha vazio para pular)
ADMIN_LOGIN="mariana"
ADMIN_COMMENT="Administradora"
ADMIN_GROUPS=(sudo adm)

DEFAULT_PASSWORD="Senha123"   # altere aqui se quiser outra padrão

# --- 2) Funções ----------
user_exists() { id -u "$1" >/dev/null 2>&1; }

group_exists() { getent group "$1" >/dev/null 2>&1; }

ensure_group() {
  local g="$1"
  if group_exists "$g"; then
    echo "[INFO] Grupo $g já existe."
  else
    groupadd "$g"
    echo "[OK] Grupo $g criado."
  fi
}

ensure_dir() {
  local path="$1" grp="$2"
  mkdir -p "$path"
  chown root:"$grp" "$path"
  chmod 770 "$path"
  echo "[OK] Diretório $path preparado (root:$grp, 770)."
}

create_user_if_needed() {
  local login="$1" comment="$2" group="$3"
  if user_exists "$login"; then
    echo "[INFO] Usuário $login já existe; garantindo grupo $group."
    usermod -aG "$group" "$login"
  else
    useradd -m -s /bin/bash -c "$comment" -G "$group" "$login"
    echo "[OK] Usuário $login criado e adicionado ao grupo $group."
  fi
  echo "$login:$DEFAULT_PASSWORD" | chpasswd
  chage -d 0 "$login"   # força troca de senha no 1º login
}

add_to_groups() {
  local login="$1"; shift
  local join=$(IFS=, ; echo "$*")
  usermod -aG "$join" "$login"
  echo "[OK] $login adicionado aos grupos: $join"
}

# --- 3) Grupos e diretórios ----
mkdir -p "$BASE_DIR"
chmod 755 "$BASE_DIR"
echo "[OK] Base $BASE_DIR pronta."

# Itera pelas CHAVES do DIRS para evitar chave inexistente com set -u
for g in "${!DIRS[@]}"; do
  ensure_group "$g"
  dir="${DIRS[$g]}"
  ensure_dir "$dir" "$g"
done

# Diretório público/compartilhado
mkdir -p "$PUBLIC_DIR"
chmod 777 "$PUBLIC_DIR"
echo "[OK] Diretório público $PUBLIC_DIR (777)."

# --- 4) Usuários -----
for pair in "${TI_USERS[@]}"; do
  login="${pair%%:*}"; comment="${pair#*:}"
  create_user_if_needed "$login" "$comment" ti
done
for pair in "${VENDAS_USERS[@]}"; do
  login="${pair%%:*}"; comment="${pair#*:}"
  create_user_if_needed "$login" "$comment" vendas
done
for pair in "${RH_USERS[@]}"; do
  login="${pair%%:*}"; comment="${pair#*:}"
  create_user_if_needed "$login" "$comment" rh
done

# --- 5) Admin opcional ------
if [[ -n "$ADMIN_LOGIN" ]]; then
  if user_exists "$ADMIN_LOGIN"; then
    echo "[INFO] Admin $ADMIN_LOGIN já existe."
  else
    useradd -m -s /bin/bash -c "$ADMIN_COMMENT" "$ADMIN_LOGIN"
    echo "[OK] Admin $ADMIN_LOGIN criado."
    echo "$ADMIN_LOGIN:$DEFAULT_PASSWORD" | chpasswd
    chage -d 0 "$ADMIN_LOGIN"
  fi
  # Garante grupos sudo/adm (caso não existam, tenta criá-los)
  for ag in "${ADMIN_GROUPS[@]}"; do
    group_exists "$ag" || groupadd "$ag"
  done
  add_to_groups "$ADMIN_LOGIN" "${ADMIN_GROUPS[@]}"
fi

# --- 6) Relatório -----
echo "
[RELATÓRIO] Grupos -> membros e diretórios:"
for g in "${!DIRS[@]}"; do
  echo -n " - $g membros: "; getent group "$g" | awk -F: '{print $4}'
  ls -ld "${DIRS[$g]}"
done

echo "
[OK] Infraestrutura aplicada. Senha inicial: '$DEFAULT_PASSWORD' (troca forçada no 1º login)."

