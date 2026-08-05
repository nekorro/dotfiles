# Model Router Zsh Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `model-router` zsh command that forwards all arguments to the GitHub-hosted `opencode-model-router` CLI.

**Architecture:** A single sourced zsh file defines one function. The function invokes `bunx` with the fixed GitHub package spec and preserves the wrapped CLI's arguments, output, and exit status.

**Tech Stack:** zsh, Bun `bunx`, GitHub package spec

## Global Constraints

- Create only `~/.config/zsh/plugins/model-router.zsh` for the runtime implementation.
- Do not add mutable global shell variables.
- Forward arguments unchanged with `"$@"`.
- Do not commit dotfiles unless the user explicitly requests it.

---

### Task 1: Add The Model Router Wrapper

**Files:**
- Create: `~/.config/zsh/plugins/model-router.zsh`
- Test: isolated `zsh -fc` shell commands

**Interfaces:**
- Consumes: `bunx` available on `PATH` and the package spec `opencode-model-router@git+https://github.com/nekorro/opencode-model-router.git#main`.
- Produces: `model-router [arguments...]`, returning the wrapped CLI exit status.

- [ ] **Step 1: Verify the command does not exist before implementation**

Run:

```bash
zsh -fc 'source "$HOME/.config/zsh/plugins/model-router.zsh"; whence -w model-router'
```

Expected: FAIL because `model-router.zsh` does not exist or `model-router` is not defined.

- [ ] **Step 2: Create the minimal plugin**

Create `~/.config/zsh/plugins/model-router.zsh` with:

```zsh
#!/usr/bin/env zsh

model-router() {
  bunx --package \
    "opencode-model-router@git+https://github.com/nekorro/opencode-model-router.git#main" \
    opencode-model-router "$@"
}
```

- [ ] **Step 3: Verify function registration**

Run:

```bash
zsh -fc 'source "$HOME/.config/zsh/plugins/model-router.zsh"; whence -w model-router'
```

Expected: exit status `0` and output `model-router: function`.

- [ ] **Step 4: Verify the wrapped CLI**

Run:

```bash
zsh -fc 'source "$HOME/.config/zsh/plugins/model-router.zsh"; model-router --help'
```

Expected: exit status `0`; output includes `opencode-model-router setup`, `sync`, `validate`, and `doctor`.

- [ ] **Step 5: Verify exit-status forwarding**

Run:

```bash
zsh -fc 'source "$HOME/.config/zsh/plugins/model-router.zsh"; model-router unknown-command >/dev/null 2>&1; [[ $? -eq 1 ]]'
```

Expected: exit status `0`, proving the function returned the wrapped CLI's status `1`.
