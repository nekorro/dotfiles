# Dotfiles

Personal development-environment configuration managed with [GNU Stow](https://www.gnu.org/software/stow/). The repository targets macOS first and keeps partial Linux support for the shell and command-line toolchain.

The setup includes Zsh, Mise, Ghostty, WezTerm, Neovim, Television, Karabiner-Elements, Codex, shared agent skills, and a collection of small workflow helpers.

## Requirements

At minimum, a new machine needs:

- Git;
- Bash and Zsh;
- network access for package managers, Mise, Zap, and Git submodules;
- Homebrew on macOS, or APT on Debian/Ubuntu Linux;
- GitHub SSH access for this repository and the `nvim` and `colorscheme` submodules.

Some packages have additional runtime dependencies:

- the terminal configurations expect a FiraCode Nerd Font;
- Codex hooks use `jq`;
- the Zsh helpers use tools such as `fzf`, `yq`, `ripgrep`, `bat`, `zoxide`, and `mise`;
- Arcadia-specific helpers expect `arc` and `ya` to be available;
- Karabiner configuration is macOS-only.

## Quick start

Clone recursively so every submodule is available before Stow creates links:

```bash
git clone --recurse-submodules git@github.com:nekorro/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

If the repository was cloned without submodules:

```bash
git -C ~/dotfiles submodule update --init --recursive
```

### Installer warning

`install.sh` is a full machine bootstrap, not a dry-run installer. It:

1. updates Homebrew or APT metadata;
2. installs Stow and Mise;
3. installs the configured command-line tools;
4. installs Zap when it is missing;
5. initializes all Git submodules;
6. Stows the configured packages into the home directory;
7. runs `mise install --jobs=1`;
8. removes an existing `~/.zshrc` before Stowing the repository version;
9. removes an existing `~/.config/television` before Stowing the repository version.

Back up those two paths before running the full installer on an existing machine. Use the selective commands in [Manual Stow usage](#manual-stow-usage) when only part of the setup is wanted.

The installer currently Stows:

```text
mise wezterm colorscheme nvim karabiner codex agents zsh television
```

Ghostty is intentionally installed manually so it can coexist with WezTerm.

## Repository layout

Each top-level Stow package mirrors its final path relative to `$HOME`:

```text
dotfiles/
├── agents/       # selected shared skills under ~/.agents/skills
├── codex/        # portable, user-authored parts of ~/.codex
├── colorscheme/  # kanagawa-paper.nvim submodule
├── ghostty/      # Ghostty config and theme
├── karabiner/    # Karabiner-Elements config
├── mise/         # language and CLI tool versions
├── nvim/         # Neovim config submodule
├── sources/      # source repositories used by shared skills
├── television/   # Television config and cable channels
├── wezterm/      # WezTerm config
├── zsh/          # .zshrc and shell plugins
├── install.sh    # macOS/Linux bootstrap
└── setup/        # older focused bootstrap helpers
```

For example, Stowing `ghostty` links `ghostty/.config/ghostty` into `~/.config/ghostty`.

## Package catalog

| Package | Destination | Purpose |
| --- | --- | --- |
| `zsh` | `~/.zshrc`, `~/.config/zsh` | Zap setup, completion, history, aliases, model routing, task/token helpers, Claude/OpenCode helpers, and Arcadia workflows. |
| `mise` | `~/.config/mise` | Pins language runtimes and installs commonly used CLI tools. |
| `ghostty` | `~/.config/ghostty` | Ghostty appearance, key bindings, split navigation, and the Kanagawa Paper Ash theme. |
| `wezterm` | `~/.config/wezterm` | WezTerm appearance, tabs, panes, and terminal key bindings. |
| `nvim` | `~/.config/nvim` | Neovim/LazyVim configuration stored as a Git submodule. |
| `colorscheme` | `~/.config/colorscheme` | Kanagawa Paper theme source stored as a Git submodule. |
| `television` | `~/.config/television` | Television configuration plus cable channels for files, Git, containers, packages, histories, and other selectors. |
| `karabiner` | `~/.config/karabiner` | Karabiner-Elements profiles and local automatic backups. |
| `codex` | selected paths under `~/.codex` | Portable Codex configuration, instructions, hooks, MCP launcher, and the personal `commit` skill. |
| `agents` | selected paths under `~/.agents/skills` | Exactly `ast-index`, `external-memory`, and `handoff`. |

### Zsh helpers

The Zsh package is intentionally modular. It stores small plugins under `~/.config/zsh/plugins`. The current `.zshrc` loads the core tool integrations plus the Yandex, secrets, Arcadia mount, and task helpers; the other tracked helpers can be enabled with an additional `plug` entry.

The package includes:

- Mise, Zoxide, Eza, Bat, Ripgrep, Vim, and Television integration;
- Arcadia mount and prompt helpers;
- task selection backed by `tasks.json` and `yq`;
- token-file loading based on service metadata in `tokens.yaml`;
- Claude session lookup/resume helpers;
- OpenCode defaults;
- the local model-router helper.

Some helpers are environment-specific. They are safe to load conditionally, but only become useful when the corresponding Yandex or local tools are installed.

### Mise toolchain

The tracked Mise configuration installs pinned language runtimes and general-purpose tools. The current set includes Rust, Python, Go, Node.js, Fzf, Ripgrep, fd, Eza, Stylua, Zoxide, Bat, shfmt, uv, yq, and the GitHub CLI.

Run this after editing the Mise configuration:

```bash
mise install --jobs=1
```

### Ghostty and WezTerm

Both terminal configurations are kept in parallel. The full installer Stows WezTerm; Ghostty can be enabled separately:

```bash
stow -d ~/dotfiles -t ~ ghostty
```

This does not remove or modify WezTerm.

### Neovim and colorscheme submodules

Neovim and the Kanagawa Paper colorscheme are independent repositories mounted inside their Stow packages:

```text
nvim/.config/nvim
colorscheme/.config/colorscheme
```

Their commits must be pushed in their own repositories before updating the gitlink in this repository.

### Codex

The Codex package contains only durable, user-authored configuration:

- `AGENTS.md` with global working rules;
- `config.toml` with model, permissions, TUI, hook, and MCP settings;
- `hooks.json` and the Arcadia safety hooks;
- a portable Smart Connections launcher that resolves the Obsidian vault at runtime;
- the personal `commit` skill.

The package deliberately excludes machine/runtime state, including:

- `auth.json` and credentials;
- history and sessions;
- SQLite databases, logs, caches, snapshots, and temporary files;
- memories and workdocs;
- installed plugins, packages, and system-managed skills;
- the locally installed `dev-browser` skill;
- generated per-project trust and hook state.

The defensive `codex/.codex/.gitignore` allowlists only the portable paths.

### Shared agent skills

The Agents package manages exactly three entries under `~/.agents/skills`:

- `ast-index` — exposed from `sources/Claude-ast-index-search`;
- `external-memory` — exposed from `sources/obsidian-memory-skill`;
- `handoff` — tracked directly in this repository.

The first two source repositories are Git submodules. Relative links inside the Stow package expose only their nested skill directories. Every other entry under `~/.agents/skills`, including machine-specific and Arcadia-provided skills, remains local and is not owned by Stow.

## Manual Stow usage

Run Stow from any directory by specifying the repository and home targets explicitly.

### Preview a package

```bash
stow --no --verbose=2 -d ~/dotfiles -t ~ ghostty
```

### Install one or more packages

```bash
stow -d ~/dotfiles -t ~ ghostty
stow -d ~/dotfiles -t ~ codex agents
```

### Reconcile links after changing a package

```bash
stow --restow -d ~/dotfiles -t ~ codex agents
```

### Remove managed links

```bash
stow --delete -d ~/dotfiles -t ~ ghostty
```

Deleting Stow links does not delete files stored in the repository. It can expose files that previously existed behind those links, so preview and inspect the destination first.

Avoid `stow --adopt` unless the resulting repository diff has been reviewed carefully: it moves conflicting destination files into the Stow package.

## Secrets and machine-local state

Credential values do not belong in this repository.

The Zsh package loads an optional file at:

```text
~/.config/zsh/plugins/secrets.zsh
```

The corresponding repository path is ignored. Create it locally for exported secrets:

```bash
touch ~/.config/zsh/plugins/secrets.zsh
chmod 600 ~/.config/zsh/plugins/secrets.zsh
```

`zsh/.config/zsh/plugins/token/tokens.yaml` is a catalog, not a credential store. It tracks service descriptions, OAuth endpoints, token-file locations, and environment-variable names. Actual token values remain in the referenced local files.

Other machine-local examples include Codex authentication/runtime state, agent skills not owned by the `agents` package, and application caches. Check `git status` and the staged diff before every commit.

## Updating

### Update the parent repository

```bash
git -C ~/dotfiles pull --ff-only
git -C ~/dotfiles submodule update --init --recursive
stow --restow -d ~/dotfiles -t ~ mise wezterm colorscheme nvim karabiner codex agents zsh television
```

Restow Ghostty separately if it is enabled:

```bash
stow --restow -d ~/dotfiles -t ~ ghostty
```

### Update a submodule to its recorded commit

```bash
git -C ~/dotfiles submodule update --init --recursive
```

### Advance a submodule intentionally

Enter the submodule, update and publish it there, then record the new commit in the parent repository:

```bash
git -C ~/dotfiles/nvim/.config/nvim switch main
git -C ~/dotfiles/nvim/.config/nvim pull --ff-only
# edit, validate, commit, and push inside the submodule
git -C ~/dotfiles add nvim/.config/nvim
git -C ~/dotfiles commit -m "chore(nvim): update configuration"
```

Never publish a parent gitlink that points to an unpushed submodule commit.

## Adding a Stow package

Create a top-level directory that mirrors the path below `$HOME`. For a tool that reads `~/.config/example/config.toml`:

```bash
mkdir -p ~/dotfiles/example/.config/example
cp ~/.config/example/config.toml ~/dotfiles/example/.config/example/config.toml
stow --no --verbose=2 -d ~/dotfiles -t ~ example
```

After reviewing the dry-run, move the original destination out of the way and Stow the package. Do not use destructive broad removals; back up only the exact path being replaced.

If the package should be part of a full bootstrap, add its Stow command to `install.sh`. Optional packages can remain manual.

## Recovery

If Stow reports a conflict:

1. stop before using `--adopt`;
2. inspect the exact destination with `ls -la` and `readlink`;
3. compare it with the repository version;
4. move only that destination to a backup directory;
5. repeat the dry-run;
6. install once the planned links are the only reported actions.

To restore a manually backed-up file, delete only the corresponding Stow link and move the backup back to its original path.

## Troubleshooting

### A submodule directory is empty

```bash
git -C ~/dotfiles submodule update --init --recursive
```

If an SSH-backed submodule fails with `Permission denied (publickey)`, restore GitHub SSH access or use an authorized HTTPS remote.

### Stow reports an existing target

Use a verbose dry-run to identify the exact conflict:

```bash
stow --no --verbose=2 -d ~/dotfiles -t ~ <package>
```

Do not remove an entire configuration directory when only one leaf conflicts.

### Codex cannot load its configuration

Validate the installed TOML with the Codex binary:

```bash
codex --strict-config exec --help
```

Also verify that `~/.codex/config.toml`, hooks, and skills resolve through the expected Stow links.

### Smart Connections cannot find the vault

The launcher expects the external-memory skill at `~/.agents/skills/external-memory` and runs its `resolve-vault.sh`. Initialize the source submodule, restow `agents`, and confirm that the resolver returns a valid Obsidian vault.

### A local agent skill disappeared

The `agents` package should own only `ast-index`, `external-memory`, and `handoff`. Compare the remaining entries with a pre-install inventory and restore unrelated skills from their original local source. Do not Stow the entire `.agents/skills` directory as one folded link on an existing machine.

### The full installer is too invasive

Install Stow yourself and use [Manual Stow usage](#manual-stow-usage). This avoids package-manager updates and the installer's explicit replacement of `.zshrc` and Television configuration.
