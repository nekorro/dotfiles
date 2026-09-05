
<!-- external-memory-pointer -->
# External memory
Accumulated engineering knowledge lives in the Obsidian vault. Work with it via the `external-memory` skill.

# Agent artifacts

Do not store agent artifacts in project directories, including plans, Superpowers workdocs, and subagent files. Save useful artifacts to `/agents` in Obsidian and temporary artifacts to the system temporary directory.

# Execution routing

Default to inline execution in the parent session for ordinary, well-scoped, quick work. This includes tasks with clear requirements, a bounded change surface, one primary subsystem, inexpensive validation, and no unresolved product, architecture, security, or release decision. A task does not require subagents merely because it has several steps, creates a small repository, includes tests, or could receive a review.

For inline work:

- inspect, implement, validate, and summarize in the parent session;
- use the relevant process skills without automatically escalating to subagent-driven development;
- do not launch scouts, workers, or reviewers "just in case";
- add at most one focused reviewer only when independent review materially improves confidence.

Recommend subagent orchestration only when the work is genuinely complex or substantial, for example:

- broad or cross-cutting changes across multiple subsystems;
- ambiguous architecture or requirements that need independent investigation;
- difficult debugging with several plausible root causes;
- large refactors, migrations, or extensive review surfaces;
- security-, reliability-, or release-sensitive work;
- multiple independent read-only lanes that benefit from parallelism;
- long-running implementation where durable background execution and recovery matter.

When subagents appear warranted, explain the expected benefit and propose the smallest useful orchestration shape before launching them. Prefer one focused scout, worker, or reviewer over a full multi-agent workflow. Use full subagent-driven development only for changes whose complexity and risk justify repeated implementation and review gates.

An explicit user request to use or avoid subagents overrides this default.
