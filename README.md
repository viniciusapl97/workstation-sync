# workstation-sync

Monta o meu Omarchy num PC recém-formatado com o que uso no notebook.

## PC novo

1. Instale o Omarchy normalmente (o layout de teclado escolhido no instalador
   continua valendo; o setup não mexe nele).
2. Depois de entrar na sessão:

```bash
git clone https://github.com/viniciusapl97/workstation-sync ~/Projects/workstation-sync
~/Projects/workstation-sync/setup.sh
```

Ele pede o login do GitHub (navegador) e a senha do sudo, e faz, nesta ordem:

| Etapa | O quê |
|---|---|
| `ferramentas` | `mise install` com o `config.toml` daqui: claude, codex, copilot, gh, node, opencode, uv |
| `github` | `gh auth login`, credenciais do git, nome e e-mail |
| `pacotes` | `packages.txt` via yay; Steam e Voxtype pelos instaladores do Omarchy |
| `plugins` | `plugins.txt`: MyBar, MyDock, organizer, Keyboard, Galaxy Buds, Lock Explorer, Omaland, Flux |
| `configs` | `files.txt` (cópias em `home/`): Hyprland, `shell.json`, MyBar, hooks de tema, terminais, webapps, `bt-agent` |
| `wallpapers` | clona [wallpapers](https://github.com/viniciusapl97/wallpapers) em `~/.config/omarchy/backgrounds` e roda o `install.sh` dele |
| `icones` | Reversal (as cores que o hook de ícones usa) |
| `padroes` | kitty, Brave e Claude como terminal, navegador e agente padrão |
| `repos` | `sync-repos.sh`: projetos em `~/Projects` |
| `fim` | confere a config do Hyprland, recarrega, reinicia o shell e reaplica o tema |

Pode rodar de novo, ou só algumas etapas: `./setup.sh configs plugins`.
Arquivo que já existia e muda vai antes para
`~/.local/state/workstation-sync/backup-<data>/`.

### Fica à mão

- Chaves SSH e o que mais for segredo (nada disso está aqui).
- Monitores: MyBar → Tela (`Super+P`). `monitors.lua` é de cada máquina.
- Teclado: o painel Keyboard ajusta o layout deste PC (o R85HE já vem como US Intl).
- Cidade do clima no MyBar.
- Celular no Flux (parear de novo) e Galaxy Buds.
- Hermes/Telegram: o gateway fica só numa máquina (o bot é um só).
- Outros agentes (gemini, grok, crush...): `omarchy default agent <nome>` instala.

## Neste notebook: manter atualizado

Mudou alguma config, instalou pacote ou plugin? Rode:

```bash
./capture.sh     # copia os arquivos de files.txt para home/ e avisa do que falta nas listas
git diff         # revise
```

O `capture.sh` tira do `shell.json` os plugins que não uso mais (Shibumi,
Better Bar, omaplug, v1ni.workspaces) e do estado do MyBar os favoritos (vêm do
repositório de wallpapers), a cidade do clima e contadores.

Para incluir um arquivo novo, acrescente o caminho em `files.txt`; um pacote,
em `packages.txt` (`!pacote` marca o que fica de fora de propósito); um plugin,
em `plugins.txt`.

## Projetos

`./sync-repos.sh` clona ou atualiza os projetos (pode rodar sempre). Projeto
novo: adicione ao `REPOS` em `sync-repos.sh`. Se
`~/.config/workstation-sync/repos` existir, ela substitui o `REPOS` naquela
máquina (formato `destino|dono/repo`, uma por linha, `#` comenta, `$HOME` é
expandido).
