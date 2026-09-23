# dotfiles

Managed with [chezmoi](https://chezmoi.io). This repo is the chezmoi *source*
directory; `chezmoi apply` writes real files into `$HOME` (no symlinks).

## New machine

Do these in order in the built-in Terminal app (Ghostty isn't installed yet).

### 1. Before the terminal

- Run Software Update and sign into your Apple ID.
- Open the **App Store** and sign in. The Brewfile installs App Store apps with
  `mas`, and that fails if you're signed out.
- Install 1Password (from 1password.com for now; later the Brewfile manages
  it). Sign in, then turn on **Settings → Developer → Integrate with 1Password
  CLI**. Without it, any templated secret stops and waits for an interactive
  sign-in.
- Open **System Settings → Privacy & Security → App Management** and turn on
  **Terminal** (and Ghostty later). Without it, macOS blocks Homebrew from
  updating or adopting apps with "Operation not permitted", even under sudo.
  Quit and reopen Terminal after changing it.

### 2. Xcode Command Line Tools

These provide `git`, `make` and the compilers that Homebrew and Ruby need. A
new Mac has only a stub `git` that asks you to install them.

```sh
xcode-select --install
```

Click **Install** in the dialog and wait for it to finish (several minutes).
You don't need the full Xcode app. Check that it worked:

```sh
xcode-select -p   # prints /Library/Developer/CommandLineTools
```

### 3. Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It asks for your Mac password (nothing shows as you type) and then asks you to
press Return. It installs to `/opt/homebrew`, which isn't on your PATH yet, so
for this terminal run:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
brew --version
```

After setup, `~/.zprofile` from this repo runs that line for every shell.

### 4. chezmoi and the dotfiles

```sh
brew install chezmoi
chezmoi init --apply --source ~/dotfiles franknowinski
```

That clones this repo to `~/dotfiles`, saves `~/dotfiles` as the source in
`~/.config/chezmoi/chezmoi.toml`, and writes every config. Then the scripts
run, in order: everything in the Brewfile, oh-my-zsh, Ruby 4.0.6, TPM and its
plugins, and the macOS defaults. It also clones the nvim config to
`~/.config/nvim`. The Brewfile step is the slow one (20+ minutes), and some
casks ask for your password again.

If you see **"~/.zshrc has changed since chezmoi last wrote it"**, some
installer (Claude Code, for example) appended a line. Choose `diff` to see it.
Choose `skip` to keep your file, then copy the line into this repo with
`chezmoi re-add ~/.zshrc`. Choose `overwrite` only if you don't need the line.

If a cask fails with "Installing <app> has failed!", you probably already
downloaded that app by hand. Let Homebrew take over the copy in `/Applications`
(it asks for your password, and needs the App Management permission from step
1), then apply again:

```sh
brew install --cask --adopt 1password alfred   # whichever ones failed
```

If a step fails, fix the cause and run `chezmoi apply -v` again. Scripts that
already succeeded don't run again.

### 5. Restart the terminal

Quit Terminal and open **Ghostty**. You should see the p10k prompt with the
Meslo Nerd Font icons. Log out and back in once so the macOS defaults (key
repeat, Dock) take effect.

### 6. GitHub and projects

1. `gh auth login` (scopes: `repo`, `read:org`, `workflow`, `gist`).
2. Clone the projects:

   ```sh
   for r in fivepicks halfsies pickup-pal; do gh repo clone franknowinski/$r ~/Projects/$r; done
   ```

3. Restore each Rails app's keys from 1Password, e.g.

   ```sh
   op read "op://Personal/fivepicks secrets/master.key/RAILS_MASTER_KEY" > config/master.key
   ```

4. Per project: `bundle install`, then `bin/rails db:prepare`.
5. Open nvim once so lazy.nvim installs the plugins.

### 7. By hand

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
- `50` — sort order, so `brew bundle` (15) runs before Ruby (30).
- `macos-defaults` — just a name, for humans.

The scripts: 10 Homebrew (only if step 3 was skipped) · 15 `brew bundle` ·
20 oh-my-zsh · 30 Ruby 4.0.6 + fzf key bindings · 40 tmux TPM plugins ·
50 macOS defaults (key repeat, Finder, Dock). `brew bundle` has to come before
30 and 40, which need `rbenv` and `tmux` from the Brewfile.

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
.chezmoi.toml.tmpl        becomes ~/.config/chezmoi/chezmoi.toml (sets sourceDir)
.chezmoiexternal.toml     clones franknowinski/nvim into ~/.config/nvim
.chezmoiscripts/          setup scripts, in numbered order
```
