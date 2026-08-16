#!/bin/zsh
# claude-resume — global Claude Code session finder + resume.
#
# Functions:
#   cr                  fuzzy-pick across ALL sessions (any project), then
#                       cd into the session's project dir and `claude --resume`.
#   cr <text>           pre-filter to sessions whose transcript contains <text>.
#   cr -c               only sessions of the current directory's project.
#   cr -c <text>        current-dir sessions, pre-filtered by text.
#   crf [...]           same as cr, but fork the session (--fork-session):
#                       resume into a new id, leaving the original untouched.
#
# Requires: python3, fzf.

CLAUDE_RESUME_HELPER="${0:A:h}/claude-sessions.py"

# internal: expand -c/--current to "--cwd $PWD", pass everything else through
_cr_args() {
  _cr_extra=()
  local a
  for a in "$@"; do
    case "$a" in
      -c|--current) _cr_extra+=(--cwd "$PWD") ;;
      *)            _cr_extra+=("$a") ;;
    esac
  done
}

# internal: run the picker; echoes the selected TSV row
_cr_pick() {
  local header="$1"; shift
  _cr_args "$@"
  "$CLAUDE_RESUME_HELPER" list "${_cr_extra[@]}" \
    | fzf --ansi --no-sort --delimiter='\t' --with-nth=1,2,3 \
          --preview="$CLAUDE_RESUME_HELPER preview {5}" \
          --preview-window='down,45%,wrap' \
          --header="$header"
}

cr() {
  local sel cwd sid
  sel=$(_cr_pick 'Enter: resume session in its project dir  |  type to filter' "$@") || return
  [[ -z "$sel" ]] && return
  cwd=$(printf '%s' "$sel" | cut -f2)
  sid=$(printf '%s' "$sel" | cut -f4)
  if [[ -z "$sid" || -z "$cwd" ]]; then
    echo "cr: no session selected" >&2
    return 1
  fi
  if [[ ! -d "$cwd" ]]; then
    echo "cr: project dir no longer exists: $cwd" >&2
    return 1
  fi
  cd "$cwd" || return
  echo "→ $cwd  (resume ${sid})"
  claude --resume "$sid"
}

crf() {
  local sel cwd sid
  sel=$(_cr_pick 'Enter: FORK + resume session in its project dir' "$@") || return
  [[ -z "$sel" ]] && return
  cwd=$(printf '%s' "$sel" | cut -f2)
  sid=$(printf '%s' "$sel" | cut -f4)
  [[ -z "$sid" || -z "$cwd" || ! -d "$cwd" ]] && { echo "cr: bad selection" >&2; return 1; }
  cd "$cwd" || return
  echo "→ $cwd  (fork+resume ${sid})"
  claude --resume "$sid" --fork-session
}
