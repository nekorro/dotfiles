opencode() {
  case "$1" in
    run)
      shift
      command opencode run --auto "$@"
      ;;
    completion|acp|mcp|attach|debug|providers|auth|agent|upgrade|uninstall|serve|web|models|stats|export|import|github|pr|session|plugin|plug|db)
      command opencode "$@"
      ;;
    *)
      command opencode --auto "$@"
      ;;
  esac
}
