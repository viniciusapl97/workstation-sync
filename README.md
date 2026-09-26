# workstation-sync

Scripts para restaurar minha estação depois de formatar. São independentes.

```bash
git clone https://github.com/viniciusapl97/workstation-sync ~/Projects/workstation-sync
cd ~/Projects/workstation-sync
```

- `./sync-repos.sh`: clona ou atualiza meus repositórios (Arch/Omarchy ou Fedora). Pode rodar sempre que quiser.
- `./apply-dotfiles.sh`: aplica os dotfiles via chezmoi (feitos para Fedora + niri). Mostra o diff e pede confirmação.

Projeto novo: adicione ao array `REPOS` em `sync-repos.sh`.
