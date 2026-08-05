#!/usr/bin/env zsh

model-router() {
  bunx --package \
    "opencode-model-router@git+https://github.com/nekorro/opencode-model-router.git#main" \
    opencode-model-router "$@"
}
