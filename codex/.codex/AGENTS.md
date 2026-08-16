# Global Codex Instructions

## Agent work documents

- Codex MUST store every agent-generated work document in the resolved Obsidian vault under `agents/workdocs/`. This includes implementation plans, investigation and audit reports, handoffs, scratch notes, checklists, design drafts, and other documents created primarily for agent work.
- Before writing such a document, resolve the vault path with `bash ~/.agents/skills/external-memory/scripts/resolve-vault.sh`. Never hardcode the vault root.
- Within `agents/workdocs/`, use a project-specific subdirectory when the work belongs to a repository or service.
- Codex MUST NOT create agent work documents anywhere inside an Arcadia checkout. In particular, do not create `docs/superpowers/`, `docs/plans/`, `plans/`, `workdocs/`, handoff files, or equivalent agent-only artifacts in Arcadia.
- If another skill defaults to a repository-local path for plans or workdocs, this global rule overrides that default: write the artifact to Obsidian `agents/workdocs/` instead.
- Repository documentation in Arcadia is allowed only when the user explicitly requests documentation intended to be part of the product or service repository, or when the task explicitly requires updating existing repository documentation.
- Never add Obsidian agent workdocs to Arcadia version control.
