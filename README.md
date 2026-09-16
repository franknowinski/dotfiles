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

7. Per project: `bundle install`, then `bin/rails db:prepare`.
8. Open nvim once so lazy.nvim installs the plugins.

Not automatable: license keys (Rectangle Pro, BetterTouchTool, Alfred) and the
accessibility permissions for Rectangle, BetterTouchTool and Logi Options+.

Hand-carry from the old machine (in no repo): `~/vimwiki/`, `~/.z`, the SSH key
or the 1Password SSH agent, `~/.claude/` and `~/.claude.json`, and
`~/Projects/*.md`.

## Day to day

| task | command | alias |
|---|---|---|
| edit a config, then apply | `chezmoi edit ~/.zshrc` | `dedit` |
| apply the source to `$HOME` | `chezmoi apply -v` | `dapply` |
| preview what apply would change | `chezmoi diff` | `ddiff` |
| short list of what's out of sync | `chezmoi status` | `dstatus` |
| capture an edit made in `$HOME` | `chezmoi re-add` | `dsave` |
| track a new file | `chezmoi add ~/.foo` | `dadd` |
| pull + apply on another machine | `chezmoi update -v` | `dpull` |
| go to this repo | `chezmoi cd` | `dots` |

Editing this repo does not change `$HOME` until you `apply`. `chezmoi diff`
shows the drift.

## Naming

A source file can't start with a dot, so a prefix says what to create:

| prefix | meaning |
|---|---|
| `dot_` | leading dot: `dot_zshrc` → `~/.zshrc` |
| `executable_` | set the +x bit |
| `private_` | mode 600 |
| `.tmpl` | run through the template engine first |

Setup scripts live in `.chezmoiscripts/` and are named
`run_<when>_<before/after>_<order>-<name>.sh`. Taking
`run_once_after_50-macos-defaults.sh` apart:

- `run_once_` — runs one time ever on a machine; chezmoi remembers it by the
  script's hash. `run_onchange_` instead re-runs whenever the script's contents
  change, which is how the Brewfile script re-runs when the Brewfile changes.
- `after` — run after the config files are written (`before` runs first).
- `50` — sort order, so Homebrew (10) runs before Ruby (30).
- `macos-defaults` — just a name, for humans.

The scripts: 10 Homebrew · 20 oh-my-zsh · 30 Ruby 4.0.6 + fzf key bindings ·
40 tmux TPM plugins · 50 macOS defaults (key repeat, Finder, Dock) ·
60 `brew bundle`.

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
