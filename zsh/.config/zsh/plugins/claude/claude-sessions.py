#!/usr/bin/env python3
"""Global Claude Code session index.

Modes:
  list [query]      -> TSV of sessions, newest first.
                       Columns: date \t cwd \t first_msg \t session_id \t filepath
                       If query is given, only sessions whose transcript
                       contains it (case-insensitive substring) are listed.
  preview <file>    -> human-readable preview of one transcript.
"""
import os
import sys
import json
import glob
import datetime

PROJECTS = os.path.expanduser("~/.claude/projects")


def iter_user_texts(path):
    """Yield plain-text user messages from a transcript, in order."""
    for line in open(path, errors="ignore"):
        try:
            o = json.loads(line)
        except Exception:
            continue
        m = o.get("message", {})
        if o.get("type") == "user" or m.get("role") == "user":
            c = m.get("content", "")
            if isinstance(c, list):
                c = " ".join(
                    x.get("text", "")
                    for x in c
                    if isinstance(x, dict) and x.get("type") == "text"
                )
            c = (c or "").strip().replace("\n", " ")
            if c and not c.startswith("<") and "Caveat" not in c \
               and "Base directory" not in c and "Request interrupted" not in c:
                yield c


def session_meta(path):
    sid = cwd = first = None
    try:
        for line in open(path, errors="ignore"):
            try:
                o = json.loads(line)
            except Exception:
                continue
            sid = sid or o.get("sessionId")
            cwd = cwd or o.get("cwd")
            if sid and cwd:
                break
    except Exception:
        return None
    if not (sid and cwd):
        return None
    for t in iter_user_texts(path):
        first = t[:80]
        break
    return sid, cwd, (first or "")


def transcripts():
    # top-level session files only; skip subagents/ to avoid duplicates
    for f in glob.glob(os.path.join(PROJECTS, "*", "*.jsonl")):
        yield f


def cmd_list(query, cwd_filter=None):
    q = query.lower() if query else None
    want = os.path.realpath(cwd_filter) if cwd_filter else None
    rows = []
    for f in transcripts():
        if q:
            try:
                if q not in open(f, errors="ignore").read().lower():
                    continue
            except Exception:
                continue
        meta = session_meta(f)
        if not meta:
            continue
        sid, cwd, first = meta
        if not first:  # no real user message -> empty session, skip
            continue
        if want and os.path.realpath(cwd) != want:
            continue
        rows.append((os.path.getmtime(f), sid, cwd, first, f))
    for mt, sid, cwd, first, f in sorted(rows, reverse=True):
        d = datetime.datetime.fromtimestamp(mt).strftime("%Y-%m-%d %H:%M")
        print(f"{d}\t{cwd}\t{first}\t{sid}\t{f}")


def cmd_preview(path):
    meta = session_meta(path)
    if meta:
        sid, cwd, _ = meta
        print(f"cwd:  {cwd}")
        print(f"id:   {sid}")
        print(f"file: {path}")
        print("-" * 60)
    for i, t in enumerate(iter_user_texts(path)):
        if i >= 25:
            print("…")
            break
        print(f"▸ {t[:200]}")


def main():
    args = sys.argv[1:]
    mode = args[0] if args else "list"
    if mode == "preview":
        cmd_preview(args[1])
        return
    if mode == "list":
        args = args[1:]
    # parse optional --cwd PATH out of the remaining args; rest is the query
    cwd_filter = None
    rest = []
    i = 0
    while i < len(args):
        if args[i] == "--cwd" and i + 1 < len(args):
            cwd_filter = args[i + 1]
            i += 2
            continue
        rest.append(args[i])
        i += 1
    cmd_list(" ".join(rest), cwd_filter)


if __name__ == "__main__":
    main()
