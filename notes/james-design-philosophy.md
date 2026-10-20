# Design Philosophy

Human written, not for agents!

Quick notes on why things are the way they are in this repo, why certain instructions/skills exist, etc.

## Purpose

Main goal is to mitigate as many of the issues listed in [llm-issues](./james-llm-issues.md) as I can, try and fit each agent to my workflow preferences as much as possible.

Beyond that, many instructions/skills should also provide a way to help me retain some level of ownership/understanding to the agent-generated content and provide another way to learn/develop technical + cognitive skills. As a junior, I have many gaps in knowledge where I need to build/develop cognitive and technical skills. Beyond avoiding "brain-rot", I am responsible for whatever gets shipped and any bugs, issues, damages are my fault, not the agent's fault.

## Rules

- **Extensible/Flexible**: Should be able to drop into any project and modify to project needs
- **Harness-agnostic**: Opencode, Claude Code, Pi, and whatever I may try in future (eg. Deepseek harness)
- **Model-agnostic**: Anthropic, Qwen, Deepseek, I should not be "vendor-locked", although it may be a bit difficult, my instructions should not target a single model's quirks/behavior too much
- **Improve LLM-Writing**: As mentioned in issue page, one of my biggest gripe. If I can at least cut down on some of the writing slop it outputs, this will severely make my long-running agent sessions more bearable.
- **Support varying levels of ownership/understanding**: There are tasks that I must understand key decisions, architecture, approaches. Other tasks/projects, especially demo/PoC/utility projects, they can be vibe-coded with minimal input and understanding.
- **Support different modes of output**: There are a lot of times where I want/need an LLM to teach/explain a concept/design choice to me. With that, the LLM should periodically quiz/test me, make sure I understand what is going on. Then there are times where I just want to get shit done and I just want a concise summary per each step.
