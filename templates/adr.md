<!--
ADR: Architecture Decision Record. One short file recording a decision and why
it was made. The idea is from a Michael Nygard post, around 2011.

Save as docs/adr/NNNN-short-title.md, numbered in order.

Write it when the decision is made, not at the end of the project. The reasoning
is in your head and in the agent's context at that moment and nowhere else. Later,
the code shows what you did and nothing shows why. Five minutes now, or an hour of
archaeology in three months.

Immutable once accepted. Changed your mind? Write a new one and mark this one
superseded, so the history of the thinking survives.

When to bother: a decision someone could reasonably question later, where you
picked one option over another for a reason that is not obvious from the code.
Auth, schema shapes, a dependency you took on, something you deliberately did not
build. Not for forced choices, and not for anything the diff already explains.
-->

# NNNN. <decision in one line>

Date: YYYY-MM-DD
Status: accepted | superseded by [NNNN](NNNN-other.md)

## Context

- What forced a decision. 2-4 bullets.
- Constraints that ruled things out (deadline, existing schema, team skill, cost).

## Decision

- What we are doing. One or two sentences.

## Alternatives

| Option | Why not |
|---|---|
| ... | ... |

## Consequences

- What this makes easy.
- What this makes hard or expensive to change later.
- What breaks if the assumption behind it stops holding.
