# Notes

Working notes for developing this repo. Nothing here is installed into a project and nothing here is read by an agent doing normal work.

Read these when deciding what to build, change, or delete.

## Agents Read This

| File | What |
|---|---|
| `philosophy.md` | Design rules for this repo and why they are what they are |
| `llm-issues.md` | Problems I hit with agents, what mitigates each one, what is still open |
| `testing-log.md` | Current state of real-world testing. Read this first when picking the work back up |
| `references.md` | Where the ideas came from |

`llm-issues.md` is the input to the roadmap. When an issue there has no mitigation, that is the argument for the next thing to build. When a mitigation stops working after a model change, record it there rather than quietly tolerating it.

As of 2026-10-20, nothing in this repo has been run on a real project. `testing-log.md` says what to watch for and names the gaps that are already known, including that the eager and routed split does not yet work under Opencode.

## James/Human Read This

Agents ignore:

- [My Design Philosophy](./james-design-philosophy.md)
- [My List of Encountered Issues](./james-llm-issues.md)
