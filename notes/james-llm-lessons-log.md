# Log of Lessons Learned

My log of things I learned during my usage of LLM agents in my dev workflows.

## General Tips

### Instructions/Skills

- Avoid super-long bloated `AGENTS.md`, put core commands, rules, instructions in there, reference other docs, instructions, skills so agent can lazy-load them
- Not every instruction/skill needs to be loaded every session, certain things can be lazy-loaded
- Be concise in instructions

### Context Management

- Write important notes, logs, decisions to disk to avoid losing them on compaction
- Use sub-agents where appropriate. While harness usually handles this automatically, there are times where you still need to explicitly instruct main agent to launch sub-agents. Examples of when to use sub-agents:
  - reading/summarizing logs from external source
  - research task, eg. explore repo
- After 2-3 compactions, consider making fresh session, faced severe deterioration from my own experience after couple compactions

### Token Management

Dependent on task complexity, token constraints, resource constraints, etc. For example, work I have constraint of $100 API usage per day which I can easily hit on larger tasks. Outside of work I rarely hit limit on LLM subscriptions for personal projects.

- Consider using smarter model for high-level planning, cheaper model for implementing grunt-work tasks like writing code, executing scripts, etc.
- New session for new topic/task, avoid pulling from unrelated context
- Prioritize what can/should be done by LLM, eg. small config changes can be quickly done by hand, or what model should be used, eg. no need to default to most expensive model, start at mid-range model if unsure of task complexity
- Concise prompts and instructions

### Tooling

- Avoid bloating MCP tools, agents do not need 10+ MCP tools globally for every project, scope down to per-project, sweet spot probably 2-5 tools
- Provide linters and LSPs to improve code quality, ensure LLMs write tests to suite to project needs
- Agents have tendency to write lots of Python scripts to execute more complex commands locally, see what repetitive tasks it's doing and provide alternative tool and/or vibe-code a utility tool for those tasks

### Docs/Wiki

- Remove stale, inaccurate/wrong docs/code comments. Had issue at work where a bad human-written comment lead the agent astray
- Add date to journals/logs (if not tracked via git), that way LLM can flag potential stale files to review
- For docs that will reach other viewers, write/edit by-hand, if I don't enjoy reading AI docs, I shouldn't subjugate other to read them. If the intended audience is just me or the agent, then it's fine to let LLM handle it

### Agent Harness

- Claude Code is locked to Anthropic, so risk of vendor-lock, but is widely-used so many tips/tricks seen online is often Claude-Code related
- Opencode can work with all APIs, including local models, way more flexibility, less used and in my experience lags a bit behind Claude Code in terms of output quality, but I prefer Opencode long-term to avoid lock-in and to support open source
- Opencode pre-loads a lot, it'll easily eat up tons of context every new session, a huge issue for local models with smaller context windows
- Consider trying Pi for more extensible and light-weight harness, particularly for local models

## Local LLMs

Haven't done too much with local LLMs.

- Smaller models (9B and under) are not suitable for my more "complicated/complex" tasks at work (or at least with my configurations), better for quick conversation/scripts or anything I don't want to consume/reach cloud services
- Context windows are small, many of the Qwen models that are runnable on my GPU are like 128k context window, whereas I'm used to the 1M context window of say Opus/Sonnet 5.5
- llama-cli arguments needs tweaking, my raw runs felt extremely slow, need to research ways to improve token generation beyond just getting a better GPU
