# Model Router Zsh Plugin Design

## Goal

Provide a `model-router` shell command that exposes the GitHub-hosted
`opencode-model-router` CLI without requiring callers to repeat its `bunx`
package specification.

## Interface

The plugin defines one zsh function:

```text
model-router [CLI arguments...]
```

It forwards every argument unchanged to the package CLI, including `setup`,
`sync`, `validate`, `doctor`, `--help`, and `--config-dir`.

## Implementation

Create `~/.config/zsh/plugins/model-router.zsh`. The function invokes:

```text
bunx --package opencode-model-router@git+https://github.com/nekorro/opencode-model-router.git#main opencode-model-router
```

The package spec is local to the function so the plugin does not add a mutable
global shell variable. The function returns the `bunx` exit status and does not
alter output, arguments, or environment variables.

## Verification

Start an isolated zsh, source the plugin, and verify that
`model-router --help` exits successfully and prints the package command list.
Also verify that `model-router` is registered as a shell function.
