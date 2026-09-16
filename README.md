# dotfiles

Managed with [chezmoi](https://chezmoi.io). This repo is the chezmoi *source*
directory; `chezmoi apply` writes real files into `$HOME` (no symlinks).

## New machine

1. Sign into 1Password, then turn on **Settings → Developer → Integrate with
   1Password CLI**. Without it, any templated secret blocks on an interactive
   sign-in.
2. Sign into the App Store (the Brewfile installs App Store apps via `mas`).
3. One command:

   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source ~/dotfiles franknowinski
   ```

   That clones this repo to `~/dotfiles`, installs Homebrew and everything in
   the Brewfile, installs oh-my-zsh, Ruby 4.0.6, TPM and its plugins, sets the
   macOS defaults, writes every config, and clones the nvim config to
   `~/.config/nvim`.
4. `gh auth login` (scopes: `repo`, `read:org`, `workflow`, `gist`).
5. Clone the projects:

   ```sh
   for r in fivepicks halfsies pickup-pal; do gh repo clone franknowinski/$r ~/Projects/$r; done
   ```

6. Restore each Rails app's keys from 1Password, e.g.

   ```sh
   op read "op://Personal/fivepicks secrets/master.key/RAILS_MASTER_KEY" > config/master.key
   ```

## Day to day

| task | command |
|---|---|
| edit a config | `chezmoi edit ~/.zshrc` then `chezmoi apply` |
| capture an edit made in `$HOME` | `chezmoi re-add` |
| track a new file | `chezmoi add ~/.foo` |
| go to this repo | `chezmoi cd` (aliased to `dots`) |
| preview changes | `chezmoi diff` |
| pull + apply elsewhere | `chezmoi update` |

Editing this repo does not change `$HOME` until you `apply`. `chezmoi diff`
shows the drift.

## Naming

`dot_` → leading dot, `private_` → mode 600, `executable_` → +x, `.tmpl` → run
through the template engine, `run_once_` / `run_onchange_` → setup scripts in
`.chezmoiscripts/`. So `dot_zshrc` becomes `~/.zshrc`.

## Layout

```
Brewfile                  every program; brew bundle installs them
dot_zshrc                 → ~/.zshrc
dot_aliases.zsh           → ~/.aliases.zsh (sourced by .zshrc)
dot_zprofile dot_zshenv   → ~/.zprofile, ~/.zshenv
dot_gitconfig             → ~/.gitconfig
dot_gitignore_global      → ~/.gitignore_global
dot_tmux.conf             → ~/.tmux.conf
dot_p10k.zsh              → ~/.p10k.zsh
dot_config/ghostty/config → ~/.config/ghostty/config
bin/executable_tmux-dev.sh → ~/bin/tmux-dev.sh (+x), on PATH
.chezmoiexternal.toml     clones franknowinski/nvim into ~/.config/nvim
.chezmoiscripts/          setup scripts, in numbered order
```
