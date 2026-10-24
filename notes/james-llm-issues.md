<!-- style-check: skip-file (quotes the banned patterns on purpose) -->

# My LLM Agent Issues

Human written, not for agents!

## Background (Skip)

<details>
<summary>TLDR - Started heavily integrating AI agents to workflow in mid-2026, hit many pain-points listed in this file. This repo aims to mitigate them.</summary>

So I started using LLMs in 2025, but overall I didn't use it too much and mainly relied on web chat interface to copy and paste snippets or discuss ideas/plans. This was a terrible and inefficient experience, hence why I didn't bother too much with LLMs at the time.

At around mid-2026, I've decided to try and integrate LLM agents heavily into my workflow to speed up development. During this timespan, I've mainly used Opencode and Claude Code as my harness with either Anthropic models (work-provided) and dabbled with couple other models (Deepseek, Qwen, GPT 5-6 Luna, etc). I felt (key word being felt) a great deal of productivity boost, but this likely came at the cost of technical debt + cognitive debt as many times I would completely offload my task and understanding to the agent in an effort to close out tasks faster.

During this period, I've hit a lot of issues and annoyances with "agentic development", tracked with this file. Whether these will be solved with future models/harness updates remains to be seen, so rather than sit and wait I've decided to try and experiment with different skills, instructions, and what not in this repo to see if I can at the very least mitigate these issues.
</details>

## Issues I Attribute to Agents/LLM Models

These are issues I feel like are "built-in/inherent" to agents/models. I can write all the skills/instructions I want but at the end of the day there's no guarantee it'll fix the issue.

### LLM Writing

My biggest fucking gripe with LLM. I can't stand the way it talks or creates technical writings.

TLDR: Low-density writing, patterns like negative parallelism that makes reading for a human harder

#### Volume and narration

They love to produce walls of text in their responses, documentation, and whatever they fucking write. Not only is there a shit ton of words, these words often have very little substance in them (or can be written in like 20 words).

Personally, I want to be able to skim the page in ten seconds and decide whether to read it. I prefer bullet points over paragraphs (I know ironic with this file). Commands I can copy. Detail behind a link or a collapsed section if I choose to dig.

Docs that I and many others like: Stripe API, FastAPI, Django, MDN.

#### Vocabulary

Words like:

- load-bearing
- seam
- genuinely
- honestly
- smoking-gun

all are well-documented. Whether it's because of the way LLMs use them or because they're associated with LLMs now, I have grown to hate it over time.

#### Writing Patterns

Also well-documented, there is a lot of "LLM-isms" and they suck. On it's own most of these are fine, but each issue compounds to make a document super verbose/lengthy with low density.

Examples:


| LLM-ism | Example | Why I Hate It |
| ---     | ---     |  ---          |
| Negative parallelism (it's not X, it's Y. it's Y, not X) | The real bottleneck: connections, not CPU | I see this all the time and most of the time they can just say the damn thing directly |
| And the X? Y. | And the result? 10% faster performance | Sensationalized writing |
| Punchy takeaways | here's the rub. the final takeaway | Sensationalized writing |
| No X. No Y. Just Z. | No packages, no dependencies, just standard library. | Sensationalized writing |
| Excessive repetition | The [...] are real. The [...] are real. | Saw this on a HackerNews article, hate it |
| Ego-stroking/Sycophancy | That's genuinely impressive | Patronizing as shit |
| Emojis in docs | Rocket-ship | I don't need a fire emoji or rocket-ship for a shitty doc, although I don't see it much past 2025 |

This can vary between models but overall I'd say most models suffer these on a varying degree. I haven't found any prompt/instruction to fix this yet.

### Code

#### Code quality

Not a problem I face because I'm a junior, so not something I'm experienced enough to discern. For me, given a linter, tests, and basic standards, agents write better code than I do right now.

#### Comment verbosity

Agents leave five lines of comments where the code is self-documenting. `AGENTS.md` saying "1 to 3 lines" gets ignored until I repeat it in the prompt.

Decided not to chase this. Over-commenting forces me to read the code and edit by hand, which I want to be doing anyway. For agent-driven projects more comments do not hurt.

The part that does matter is accuracy. A stale comment that contradicts the code is worse than no comment. `instructions/python.md` says to delete rather than let one drift. This has caused issues in my sessions before because 1 agent's assumption that is written as a code led to another agent believing some restriction that wasn't actually an issue.

### Alignment

Sometimes a prompt problem, sometimes the agent misreading the problem. Either way I'll give it a prompt and it'll eagerly implement something that I hate afterwards or just is flat out wrong. For the most part, switching between plan/write mode has caught a lot of this issue, but not all.

- Relevant file(s): `skills/alignment`.

## Issues Caused by Me

These are definitely avoidable problems but requires me to put thought/effort into.

### Mode switching

I switch between wanting the agent to take the wheel and then I want to have more control. Adding explicit modes makes it easier without re-typing bunch of prompts to get the behavior I want.

- Relevant file(s): `instructions/modes.md` makes the choice explicit. `templates/adr.md` captures reasoning at decision time.

### Whiteboard defense

Mitchell Hashimoto's "whiteboard defense", quoted in full in `philosophy.md`. For work that I care or should care about, I need to be able to explain and defend anything I shipped, even without line-level familiarity.

- Relevant file(s): `skills/whiteboard-defense` drills me and produces a gap list. `skills/teach` closes the gaps.

### Learning

I am junior. There are times I want to be taught rather than handed a result, and the default agent behavior is to hand me the result. This requires effort on my end to not be lazy.

- Relevant file(s): `skills/teach`

### Context Management

So for long-running sessions, I've found that the agent becomes dumber and dumber, particularly after compaction(s). This is expected and my quick solution was writing certain details to disk.

Some things I need to do better:

- Have rules to explicitly launch sub-agents where appropriate
- Better instructions on updating file on disk for long-running sessions. Currently only use single `MEMORY.md` that I prompt it to update. Could have multiple files (eg. `JOURNAL.md`) and update them on important events (eg. mark down when we pick between two approaches, when assumption is wrong, etc.)
- After 2-3 compactions, start fresh. I've had a project that had like 5 compactions, it was terrible after the 3rd compaction
