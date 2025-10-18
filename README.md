# Infraestrutura como Código — Gusbaido (Linux/WSL)

Script Bash criado por **Gusbaido** para preparar automaticamente um ambiente Linux/WSL, com criação de grupos, usuários, diretórios e permissões, aplicando boas práticas de segurança e versionado em: [https://github.com/Gusbaido/LinuxGit](https://github.com/Gusbaido/LinuxGit)

## 📦 O que este script faz

* Cria grupos: **ti**, **vendas**, **rh**
* Cria diretórios: **/departamentos/{ti,vendas,rh}** (perm. 770) e **/departamentos/compartilhado** (perm. 777)
* Cria usuários padrão: **ti01**, **ti02**, **vendas01**, **vendas02**, **rh01**, **rh02**
* (Opcional) Cria **mariana** e adiciona aos grupos **sudo** e **adm**
* Define senha inicial (**Senha123**) e força troca no 1º login (`chage -d 0`)
* Mostra relatório final com grupos, membros e permissões

> **Dica:** após rodar, aplique boas práticas de segurança:
>
> ```bash
> sudo chmod 2770 /departamentos/{ti,vendas,rh}   # setgid → herda grupo automaticamente
> sudo chmod 1777 /departamentos/compartilhado    # sticky bit → impede deleção cruzada
> ```

## ✅ Requisitos

* Linux (Ubuntu/Debian/WSL) com `bash`, `sudo` e pacotes básicos
* Usuário com permissão de `sudo`
* `git` instalado para versionar

## 🚀 Como usar

1. Dê permissão de execução:

   ```bash
   chmod +x infra_users_dirs.sh
   ```
2. Execute com privilégios:

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
* `GROUPS` → grupos (`ti vendas rh`)
* `DIRS` → mapa grupo → diretório
* `DEFAULT_PASSWORD` → senha inicial (`Senha123`)
* `ADMIN_LOGIN`, `ADMIN_GROUPS` → admin opcional (`mariana`, grupos `sudo adm`)

## 🔒 Segurança e Boas Práticas

* `set -euo pipefail` para execução segura
* `chage -d 0` força redefinição da senha no primeiro login
* `setgid` mantém grupo consistente dentro das pastas
* `sticky bit` protege arquivos no diretório compartilhado

## 🧪 Testes rápidos

```bash
su - ti01
whoami && groups
cd /departamentos/ti && touch teste.txt && ls -l
cd /departamentos/vendas  # deve dar “Permissão negada”
```

## 🧭 Versionamento

```bash
git init
git add infra_users_dirs.sh README.md
git commit -m "Infraestrutura como Código - criação de grupos, usuários e diretórios"
git branch -M main
git remote add origin https://github.com/Gusbaido/LinuxGit.git
git push -u origin main
```

## 📄 Licença

MIT © 2025 [Gusbaido](https://github.com/Gusbaido)
