# Infraestrutura como Código — Usuários, Grupos, Diretórios e Permissões

Script Bash para preparar um ambiente Linux/WSL de forma automática, criando grupos, usuários, diretórios e permissões, com boas práticas de segurança (setgid/sticky opcional) e relatório final.

## 📦 O que este script faz

* Cria os grupos: **ti**, **vendas**, **rh**
* Cria os diretórios: **/departamentos/{ti,vendas,rh}** (perm. 770) e **/departamentos/compartilhado** (perm. 777)
* Cria usuários padrão: **ti01**, **ti02**, **vendas01**, **vendas02**, **rh01**, **rh02**
* (Opcional) Cria **mariana** e adiciona aos grupos **sudo** e **adm**
* Define senha inicial (**Senha123**) e força troca no 1º login (`chage -d 0`)
* Mostra relatório final com grupos, membros e permissões

> **Dica**: após rodar, você pode aplicar **setgid** nas pastas de times e **sticky bit** no compartilhado:
>
> ```bash
> sudo chmod 2770 /departamentos/{ti,vendas,rh}
> sudo chmod 1777 /departamentos/compartilhado
> ```

## ✅ Requisitos

* Linux (Ubuntu/Debian/WSL) com `bash`, `sudo` e pacotes básicos
* Usuário com permissão para executar `sudo`
* `git` instalado para versionar (opcional)

## 🚀 Como usar

1. Dê permissão de execução:

   ```bash
   chmod +x infra_users_dirs.sh
   ```
2. Rode como root/sudo:

   ```bash
   sudo ./infra_users_dirs.sh
   ```
3. Valide:

   ```bash
   getent group ti vendas rh
   ls -ld /departamentos /departamentos/{ti,vendas,rh,compartilhado}
   ```

## ⚙️ Variáveis principais (edite no topo do script)

* `BASE_DIR` → diretório base (padrão `/departamentos`)
* `GROUPS` → lista de grupos (padrão `ti vendas rh`)
* `DIRS` → mapa grupo → diretório
* `DEFAULT_PASSWORD` → senha inicial (padrão `Senha123`)
* `ADMIN_LOGIN`, `ADMIN_GROUPS` → admin opcional (padrão `mariana`, grupos `sudo adm`)

## 🔒 Segurança e boas práticas

* `set -euo pipefail` para fail-fast e variáveis obrigatórias
* **Senha inicial** é provisória; o script força troca no primeiro login
* Use **setgid** nas pastas de times para herdar grupo automaticamente
* Use **sticky bit** em `/departamentos/compartilhado` para impedir deleção cruzada

## 🧪 Testes rápidos

```bash
su - ti01
whoami && groups
cd /departamentos/ti && touch teste.txt && ls -l
cd /departamentos/vendas  # deve dar “Permissão negada”
```

## 🛠️ Troubleshooting

* `unbound variable` → confira `GROUPS=(ti vendas rh)` (sem vírgulas) e as chaves de `DIRS`
* `Operation not permitted` ao usar `chmod` em `/departamentos` → rode como **root**
* WSL: prefira criar o projeto em `~/LinuxGit` (filesystem do Linux) para manter permissões POSIX

## 🧭 Versionamento (atalho)

```bash
git init
git add infra_users_dirs.sh
git commit -m "Infraestrutura como Código: usuários, grupos e permissões"
```

Crie um repo no GitHub e faça `git remote add origin <URL>` e `git push -u origin main` (veja guia completo no passo a passo do chat).

## By GUS
