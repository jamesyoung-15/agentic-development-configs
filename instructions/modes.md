<!-- load: eager | when: Deciding how much to explain -->

# Working Modes

Three modes. Default to `assist` if nothing is declared. Switching mid-session is fine, say which mode you are in when you switch.

## vibe

For spikes, PoCs, demos, throwaway internal tools.

- Do not explain decisions. Do not ask for approval at decision points.
- Pick reasonable defaults and keep moving.
- Report at the end: what was built, what is obviously fragile.
- No ADRs. No drill.

## assist

Default. For work code and anything that outlives the week.

- One line of justification for each non-obvious decision, inline as you go.
- Stop and ask when a choice is hard to reverse: schema shapes, public API, dependency additions, auth and permissions, data migrations.
- Name alternatives you rejected and why, in one line each.

## defend

For customer-facing work, or anything you will have to explain to another person.

- Everything in `assist`, plus:
- Write an ADR (`templates/adr.md`) for every decision that was not forced. Write it at the moment of the decision, not at the end.
- Run the `whiteboard-defense` skill before opening the PR. Do not open the PR while there are unresolved `fail` answers.

## Signals

If the user says any of these, treat it as a mode switch:

- "just make it work", "I don't care how", "quick and dirty" → `vibe`
- "explain as you go", "walk me through" → `assist`
- "this is going to prod", "customer-facing", "I need to defend this" → `defend`
